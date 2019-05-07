#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [int]$MaxEvents = 1000,
    [Switch]$ShowUsernames = $false
)

$ErrorActionPreference = 'Stop'



#
# Returns the number of failed logons attempts for each source IP address.
#

$ExtraParams = @{}
if ($MaxEvents -gt 0) {
    $ExtraParams = @{MaxEvents = $MaxEvents}
}

if ($ShowUsernames) {
    $propertyIndex = 5         # Username
} else {
    $propertyIndex = 19        # Source IP
}

Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625 } @ExtraParams |
    ForEach-Object {
        $_.Properties[$propertyIndex].Value
    } |
    Group-Object -NoElement |
        Where-Object { ($_.Count -gt 10) -and ($_.Name -ne '-') } |
            Sort-Object -Property 'Count' -Descending
