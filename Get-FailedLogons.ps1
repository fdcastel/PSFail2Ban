#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [int]$MaxEvents = 1000
)

$ErrorActionPreference = 'Stop'



#
# Returns the number of failed logons attempts for each source IP address.
#

$ExtraParams = @{}
if ($MaxEvents -gt 0) {
    $ExtraParams = @{MaxEvents = $MaxEvents}
}

Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625 } @ExtraParams |
    ForEach-Object {
        $_.Properties[19].Value        # Source IP
    } |
    Group-Object -NoElement |
        Where-Object { ($_.Count -gt 10) -and ($_.Name -ne '-') } |
            Sort-Object -Property 'Count' -Descending
