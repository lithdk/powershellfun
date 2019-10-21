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
$daysup = $leuptimecalc.days
$msgForInput = "System uptime is greater than " + $daysup + " days. Turning off Fast Start-Up and rebooting might fix your problem. Do you want to open Power Options? (Y/N)"
$registryPath = "HKCU:\SOFTWARE\Microsoft\Office\15.0\Common\Identity"
$adalkey = "EnableADAL"
$versionkey = "Version"





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


if ($daysup -ge 1) {
    do { $myInput = (Read-Host $msgForInput).ToLower() } while ($myInput -notin @('y','n'))
    if ($myInput -eq 'y') {
        write-host "You've selected 'Yes'. Remember to reboot after turning off Fast Start-Up"
        control /name Microsoft.PowerOptions /page pageGlobalSettings
    } else {
        write-host "You've selected 'No'."
    }
 
}


write-host "`n`n--- MENU ---"
write-host "Enter your selection, 9 to quit"
write-host "1. Enable ADAL"
write-host "2. Disable ADAL"
write-host "3. Download teamviewer to desktop"
write-host "`n9. Exit`n"

do {
 $answer = read-host "Please Make a Selection"  

        #Enable adal
        if ($answer -eq '1') {
            echo "You selected $($answer). Enabling ADAL"
            IF(!(Test-Path $registryPath))
              {
                New-Item -Path $registryPath -Force | Out-Null
                New-ItemProperty -Path $registryPath -Name $adalkey -Value "1" -PropertyType DWORD -Force | Out-Null
                New-ItemProperty -Path $registryPath -Name $versionkey -Value "1" -PropertyType DWORD -Force | Out-Null
               }
             ELSE {
                New-ItemProperty -Path $registryPath -Name $adalkey -Value "1" -PropertyType DWORD -Force | Out-Null
                New-ItemProperty -Path $registryPath -Name $versionkey -Value "1" -PropertyType DWORD -Force | Out-Null
                }
        }
        #Disable adal
        elseif ($answer -eq '2') {
            echo "You selected $($answer). Disabling ADAL"
            IF(!(Test-Path $registryPath))
              {
                New-Item -Path $registryPath -Force | Out-Null
                New-ItemProperty -Path $registryPath -Name $adalkey -Value "0" -PropertyType DWORD -Force | Out-Null
                Remove-ItemProperty -Path $registryPath -Name $versionkey
               }
             ELSE {
                New-ItemProperty -Path $registryPath -Name $adalkey -Value "0" -PropertyType DWORD -Force | Out-Null
                Remove-ItemProperty -Path $registryPath -Name $versionkey
                }
        }
        #Download TW to desktop
        elseif ($answer -eq '3') {
            $outpath = "C:\Users\" + $env:username + "\Desktop\ITRsupport.exe"
            Invoke-WebRequest -Uri "https://www.itrelation.dk/Admin/Public/DWSDownload.aspx?File=%2fFiles%2fFiles%2fITRsupport.exe" -OutFile $outpath
            }



 } until ($answer -eq '9')
