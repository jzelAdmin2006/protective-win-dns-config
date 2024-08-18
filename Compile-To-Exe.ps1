if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    Install-Module PS2EXE -Force -Scope CurrentUser
}

ps2exe Ensure-DNS.ps1 Ensure-DNS.exe -noConsole -noOutput -requireAdmin
