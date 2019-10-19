$leuptimecalc = $uptime = (Get-Date) - ((Get-WmiObject win32_operatingsystem).ConvertToDateTime((Get-WmiObject win32_operatingsystem).lastbootuptime))
$leuptimeout = "Uptime: " + $leuptimecalc.Days + " days, " + $leuptimecalc.Hours + " hours, " + $leuptimecalc.Minutes + " minutes" 
$lehostname = $env:computername
$ledomainanduser = $(Get-WMIObject -class Win32_ComputerSystem | select username).username
$leipconfiguration = Get-NetIPConfiguration | out-string
$partOfDomain = (Get-WmiObject -Class Win32_Computersystem).PartOfDomain
$lepcinfo = systeminfo /fo csv | ConvertFrom-Csv | select OS*, System*, Hotfix* | out-string
if ($partOfDomain -eq $true) {
$ledomaintrust = Test-ComputerSecureChannel
$lelogonserver = $env:LOGONSERVER
$legpresult = gpresult /r | out-string
}

Write-Host "`n`n ----------Copy From Here----------"
Write-Host $leuptimeout
Write-Host "Computer name is: $($lehostname)"
Write-Host "Domain and username is: $($ledomainanduser)"
if ($partOfDomain -eq $true) {
Write-Host "Domain trust is currently: $($ledomaintrust)"
Write-Host "Logon server is: $($lelogonserver)"
}
Write-Host "`n"
Write-Host "`nIP interfaces are as follows:"
Write-Host $leipconfiguration
Write-Host "`nPC information:"
Write-Host $lepcinfo
if ($partOfDomain -eq $true) {
Write-Host "`nGPresult:"
Write-Host $legpresult
}

$daysup = $leuptimecalc.days
if ($daysup -ge 1) {
$msgForInput = "System uptime is greater than " + $daysup + " days. Turning off Fast Start-Up and rebooting might fix your problem. Do you want to open Power Options?"
$msgBoxInput =  [System.Windows.MessageBox]::Show($msgForInput,'Input Box','YesNo','Error')
    switch  ($msgBoxInput) {
    'Yes' {
    write-host "You've selected 'Yes'. Remember to reboot after turning off Fast Start-Up"
    control /name Microsoft.PowerOptions /page pageGlobalSettings
    }
    'No' {
    write-host "You've selected 'no'."
    }
    }

}
