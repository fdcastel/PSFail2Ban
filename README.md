# PSFail2Ban

Powershell script to block IP addresses after multiple failed logon attempts.



## How to install

Download all scripts in any folder and run (with administrative privileges):

```powershell
Install-ScheduledTask.ps1
```

This will create a scheduled task to run `Update-FirewallRule.ps1` (see below) every hour.



## How it works

The main script is `Update-FirewallRule.ps1`. It checks for Event ID 4625 entries in Windows Security logs and adds a blocking rule in Windows Firewall for every IP address with 10 or more failed logons.

Also, all blocked IPs will be saved in a `blacklist.txt`. You can change this file if needed. Addresses in this file will ALWAYS be blocked by the firewall rule even if they didn't show up in Security events.

In the same way, you could keep a `whitelist.txt`. Addresses in this file will NEVER be blocked by the firewall rule.

By default the script will check only the last 1000 events in Security log. You can use the `-MaxEvents` parameter to change this number.



## Other scripts

If you want a quick summary of failed logins, just run

```powershell
Get-FailedLogons.ps1
```

It will show the number of failed logons attempts for each source IP address.

By default the script will check only the last 1000 events in Security log. You can use the `-MaxEvents` parameter to change this number.
