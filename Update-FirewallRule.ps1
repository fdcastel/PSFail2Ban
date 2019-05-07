#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [int]$MaxEvents = 1000
)

$ErrorActionPreference = 'Stop'

$blacklistFile = Join-Path $PSScriptRoot 'blacklist.txt'
$whitelistFile = Join-Path $PSScriptRoot 'whitelist.txt'



function Get-FailedIps {
    # Get IP addresses with more than 10 failed logon attempts
    $ExtraParams = @{}
    if ($MaxEvents -gt 0) {
        $ExtraParams = @{MaxEvents = $MaxEvents}
    }

    $getFailedLogons = Join-Path $PSScriptRoot 'Get-FailedLogons.ps1'

    $failedIps = @()
    & $getFailedLogons @ExtraParams |
        ForEach-Object {
            $failedIps += $_.Name
    }

    $failedIps
}



function Get-BlockedIps {
    # Get blacklisted IPs (already blocked)
    Get-Content -Path $blacklistFile -Encoding Ascii -ErrorAction SilentlyContinue
}



function Get-AllowedIps {
    # Get whitelisted IPs
    Get-Content -Path $whitelistFile -Encoding Ascii -ErrorAction SilentlyContinue
}



#
# Main
#

$failedIps = Get-FailedIps
$blockedIps = Get-BlockedIps
$allIps = $failedIps + $blockedIps | Select-Object -Unique

# Update blacklist
$allIps | Out-File -FilePath $blacklistFile -Encoding ascii

# Remove allowed IPs
$allowedIps = Get-AllowedIps
$allIps = $allIps | Where-Object { $_ -notin $allowedIps } | Sort-Object

# Update firewall
$ruleName = 'PSFail2Ban-Block-Failed-Logons'
$ruleDisplayName = 'PSFail2Ban: Blocks IP addresses from failed logons'

if (Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue) {
    # Update rule
    Set-NetFirewallRule -Name $ruleName -RemoteAddress $allIps
} else {
    # Create rule
    New-NetFirewallRule -Name $ruleName -DisplayName $ruleDisplayName -Direction Inbound -Action Block -RemoteAddress $allIps
}
