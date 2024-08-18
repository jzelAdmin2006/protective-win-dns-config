$startupFolder = [Environment]::GetFolderPath('Startup')
$exeName = "Ensure-DNS"
$exeFileName = "$exeName.exe"
$ensureDnsExePath = "$startupFolder\$exeFileName"

function Install-Exe {
	.\Compile-To-Exe.ps1
	Move-Item -Path .\Ensure-DNS.exe -Destination $startupFolder -Force
	Start-Process -FilePath $ensureDnsExePath
}

if (Test-Path -Path $ensureDnsExePath) {
    if ((Read-Host "The file '$exeFileName' already exists in the startup folder. Do you want to overwrite it? ('starting with y' = YES, 'anything else' = NO)").ToLower().StartsWith("y")) {
		Start-Process powershell -ArgumentList "-Command", {
			foreach ($process in (Get-Process -Name $exeName -ErrorAction SilentlyContinue)) {
				Stop-Process -Id $process.id -Force
			}
		}.ToString().replace('$exeName', $exeName) -Verb RunAs -Wait
		
        Install-Exe
    }
} else {
	Install-Exe
}

Read-Host "The setup is complete..."
