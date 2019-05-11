#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [int]$LastHours = 6,
    [Switch]$ShowUsernames = $false
)

$ErrorActionPreference = 'Stop'



#
# Returns the number of failed logons attempts for each source IP address.
#

$filters = @{LogName="Security"; ID=4625 } 
if ($LastHours -gt 0) {
    $filters.StartTime = (Get-Date).AddHours($LastHours * -1)
}

if ($ShowUsernames) {
    $propertyIndex = 5         # Username
} else {
    $propertyIndex = 19        # Source IP
}

Get-WinEvent -FilterHashTable $filters |
    ForEach-Object {
        $_.Properties[$propertyIndex].Value
    } |
    Group-Object -NoElement |
        Where-Object { ($_.Count -gt 10) -and ($_.Name -ne '-') } |
            Sort-Object -Property 'Count' -Descending
