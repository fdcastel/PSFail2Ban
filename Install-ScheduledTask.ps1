$commandToRun = Join-Path $PSScriptRoot 'Update-FirewallRule.cmd'

& schtasks.exe /create /tn "PSFail2Ban - Update firewall rules" /sc HOURLY /st 00:00 /f /ru "System" /tr $commandToRun
