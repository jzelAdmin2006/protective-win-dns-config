param(
    [string]$WorkingDirectory = $(Split-Path -Parent $MyInvocation.MyCommand.Path)
)

if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Set-Location $WorkingDirectory
	
	$taskName = "Ensure-DNS"
	$exeFileName = "$taskName.exe"
	$installationFolder = "$Env:Programfiles\Protective-DNS"
	$installationExeDestination = "$installationFolder\$exeFileName"
	
	function Install-Exe {
		.\Compile-To-Exe.ps1
		New-Item -Path $installationFolder -ItemType Directory -Force
		Move-Item -Path $exeFileName -Destination $installationFolder -Force
	}

	if (Test-Path -Path $installationFolder) {
		if ((Read-Host "The installation folder '$installationFolder' already exists. Do you want to continue and potentially overwrite an existing installation? ('starting with y' = YES, 'anything else' = NO)").ToLower().StartsWith("y")) {
			Start-Process powershell -ArgumentList "-Command", {
				foreach ($process in (Get-Process -Name $taskName -ErrorAction SilentlyContinue)) {
					Stop-Process -Id $process.id -Force
				}
			}.ToString().replace('$taskName', $taskName) -Verb RunAs -Wait

			Install-Exe
		}
	} else {
		Install-Exe
	}

	if ((-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) -or (Read-Host "A scheduled task called '$taskName' already exists. Do you want to overwrite it? ('starting with y' = YES, 'anything else' = NO)").ToLower().StartsWith("y")) {
		Register-ScheduledTask -Xml (Get-Content "$taskName.xml" | Out-String) -TaskName $taskName -Force
	}

	Start-Process -FilePath $installationExeDestination
	Read-Host "The setup is complete..."
} else {
	Start-Process `
		-FilePath 'powershell' `
		-ArgumentList (
			'-File', $MyInvocation.MyCommand.Source, 
			'-WorkingDirectory', $WorkingDirectory, 
			$args | %{ $_ }
		) `
		-Verb RunAs
}
