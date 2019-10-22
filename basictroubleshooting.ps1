#Main, doesnt need a description
function main {
write-host "`n--- MAIN MENU ---"
write-host "Enter your selection, 9 to quit"
write-host "1. Collect basic info"
write-host "2. Run QuickTest"
write-host "3. Go to QuickFix menu"
write-host "`n9. Exit`n"

do {
 $answer = read-host "Please Make a Selection"  

        if ($answer -eq '1') {
        basicInfo
        }
        
        elseif ($answer -eq '2') {
        quickTest    
        }
        
        elseif ($answer -eq '3') {
        quickFix    
        }

        elseif ($answer -eq '9') {exit}

 } until ($answer -eq 'QUITFFS')
}

#Function to gather basic PC info and produce output on sreen
function basicInfo {
cls
    $leuptimecalc = (Get-Date) - ((Get-WmiObject win32_operatingsystem).ConvertToDateTime((Get-WmiObject win32_operatingsystem).lastbootuptime))
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
    $eventCritical= Get-WinEvent -maxevents 20 -FilterHashtable @{Logname='System', 'Application','application';Level=1;StartTime=[datetime]::Now.AddMonths(-1)} -ErrorAction SilentlyContinue | out-string
    $eventError = Get-WinEvent -maxevents 10 -FilterHashtable @{Logname='System', 'Application','application';Level=2;StartTime=[datetime]::Now.AddMonths(-1)} -ErrorAction SilentlyContinue | out-string


    Write-Host "`n`n"
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
    Write-Host "PC information:"
    Write-Host $lepcinfo
    if ($partOfDomain -eq $true) {
    Write-Host "`nGPresult:"
    Write-Host $legpresult
    }
    Write-Host "20 latest system 'Critical' Events: $($eventCritical)"
    Write-Host "10 latest system 'Error' Events: $($eventError)"
    
    $msgForLeaveBasicInfoInput = "Do you want to go back to the main menu? (Y)"
    do { $myInput = (Read-Host $msgForLeaveBasicInfoInput).ToLower() } while ($myInput -notin @('y'))
        if ($myInput -eq 'y') {
            write-host "You've selected 'Yes'."
            $myinput = "A" #reset
            cls
            main
        }   
}

#QuickTests. Tests uptime, domaintrust
function quickTest {
cls
    #Check for domain-trust and prompt for fix
    $partOfDomain = (Get-WmiObject -Class Win32_Computersystem).PartOfDomain
    if ($partOfDomain -eq $true) {
    $ledomaintrust = Test-ComputerSecureChannel
    }
    if ($ledomaintrust -eq $false) {
        $msgForTrustInput = "Domain trust is 'FALSE', do you want to attempt to repair it? (Have admin credentials ready) (Y/N)"
        do { $myInput = (Read-Host $msgForTrustInput).ToLower() } while ($myInput -notin @('y','n'))
        if ($myInput -eq 'y') {
            write-host "You've selected 'Yes'."
            Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
            $myinput = "A" #reset
        } else {
            write-host "You've selected 'No'."
            $myinput = "A" #reset
        }
    }

    #Check for uptime and prompt for reboot
    $leuptimecalc = (Get-Date) - ((Get-WmiObject win32_operatingsystem).ConvertToDateTime((Get-WmiObject win32_operatingsystem).lastbootuptime))
    $daysup = $leuptimecalc.days
    $msgForUpInput = "System uptime is greater than " + $daysup + " days. Turning off Fast Start-Up and rebooting might fix your problem. Do you want to open Power Options? (Y/N)"
        if ($daysup -ge 1) {
            do { $myInput = (Read-Host $msgForUpInput).ToLower() } while ($myInput -notin @('y','n'))
            if ($myInput -eq 'y') {
                write-host "You've selected 'Yes'. Remember to reboot after turning off Fast Start-Up"
                control /name Microsoft.PowerOptions /page pageGlobalSettings
                $myinput = "A" #reset
            } else {
                write-host "You've selected 'No'."
                $myinput = "A" #reset
            }
        } 

    $msgForLeaveQuickTestInput = "QuickTest complete. Do you want to go back to the main menu? (Y)"
    do { $myInput = (Read-Host $msgForLeaveQuickTestInput).ToLower() } while ($myInput -notin @('y'))
        if ($myInput -eq 'y') {
            write-host "You've selected 'Yes'."
            $myinput = "A" #reset
            cls
            main
        }   
}

#QuickFix menu
function quickFix {
cls
write-host "`n--- QuickFix MENU ---"
write-host "Enter your selection, 9 to go back to the main menu"
write-host "1. Enable ADAL"
write-host "2. Disable ADAL"
write-host "3. Download Teamviewer to desktop"
write-host "`n9. Main Menu`n"

do {
 $QFanswer = read-host "Please Make a Selection"  

        if ($QFanswer -eq '1') {
        adalSwitch "enable"
        }
        
        elseif ($QFanswer -eq '2') {
        adalSwitch "disable"
        }
        
        elseif ($QFanswer -eq '3') {
        downloadTW    
        }

        elseif ($QFanswer -eq '9') {cls; main}

 } until ($QFanswer -eq 'QUITFFS')

}

#Function to enable or disable adal
function adalSwitch {
$registryPath = "HKCU:\SOFTWARE\Microsoft\Office\15.0\Common\Identity"
$adalkey = "EnableADAL"
$versionkey = "Version"

    if ($args -eq "enable") {
        if (!(Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $adalkey -Value "1" -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $versionkey -Value "1" -PropertyType DWORD -Force | Out-Null
            } else {
            New-ItemProperty -Path $registryPath -Name $adalkey -Value "1" -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $versionkey -Value "1" -PropertyType DWORD -Force | Out-Null
            }
    } elseif ($args -eq "disable") {
        if (!(Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $adalkey -Value "0" -PropertyType DWORD -Force | Out-Null
            Remove-ItemProperty -Path $registryPath -Name $versionkey
        } else {
            New-ItemProperty -Path $registryPath -Name $adalkey -Value "0" -PropertyType DWORD -Force | Out-Null
            Remove-ItemProperty -Path $registryPath -Name $versionkey
        }
    }
}

#Function to download TW to users desktop
function downloadTW {

      $outpath = "C:\Users\" + $env:username + "\Desktop\ITRsupport.exe"
      Invoke-WebRequest -Uri "https://www.itrelation.dk/Admin/Public/DWSDownload.aspx?File=%2fFiles%2fFiles%2fITRsupport.exe" -OutFile $outpath
      Write-Host "Teamviewer is now located at: $($outpath)"

}

main

#Oneliner to run:
#$basictroubleshooting = Invoke-WebRequest https://raw.githubusercontent.com/lithdk/powershellfun/master/basictroubleshooting.ps1; Invoke-Expression $($basictroubleshooting.content)
