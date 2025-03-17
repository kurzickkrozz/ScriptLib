$target = Read-Host "Enter the IP Address"
$targetname = Read-Host "Enter the Workstation Name"
$savedir = Read-Host "Enter the DIRECTORY you want this data to be saved."
$savefile = Join-Path $savedir $targetname


# CREATE DIRECTORY
mkdir $savefile -ErrorAction SilentlyContinue
# FETCH ACCOUNTS
icm -Credential $creds -ComputerName $target -ScriptBlock {
    Get-CimInstance -ClassName Win32_UserAccount |
        Select-Object -Property Name, Disabled, PasswordRequired, SID
} >> $savefile\accounts.txt
# FETCH AUTORUNS
icm -Credential $creds -ComputerName $target -ScriptBlock {
    Get-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce"  -ErrorAction SilentlyContinue
    Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices" -ErrorAction SilentlyContinue
    Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServices" -ErrorAction SilentlyContinue
    Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue
    Get-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\SafeDllSearchMode" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\LocalAccountTokenFilterPolicy" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Notification Packages" -ErrorAction SilentlyContinue
    Get-Item -Path "HKCU:\Control Panel\Desktop\" -ErrorAction SilentlyContinue
    Get-Item -Path "HKLM:\System\CurrentControlSet\Services\W32Time\TimeProviders\" -ErrorAction SilentlyContinue
} >> $savefile\autoruns.txt
# FETCH FIREWALL
icm -Credential $creds -ComputerName $target -ScriptBlock {
    netsh advfirewall show allprofiles
} >> $savefile\firewall.txt
# FETCH PROCESSESS
icm -Credential $creds -ComputerName $target -ScriptBlock {
    gps | Select-Object -Property *
} >> $savefile\processess.txt
# FETCH SCHEDULED TASKS
icm -Credential $creds -ComputerName $target -ScriptBlock {
    schtasks /query /V /FO CSV | ConvertFrom-Csv |
        Where-Object {$_."Scheduled Task State" -eq "Enabled"} |
                Select-Object -Property TaskName,
                                        Status,
                                        "Run As User",
                                        "Schedule Time",
                                        "Next Run Time",
                                        "Last Run Time",
                                        "Start Time",
                                        "End Time",
                                        "End Date",
                                        "Task to Run",
                                        @{n="Hash";e={(Get-FileHash -Path (($_."Task to Run") -replace '\"','' -replace "\.exe.*","exe") -ErrorAction SilentlyContinue).hash}}
} >> $savefile\schtasks.txt
# FETCH SERVICES
icm -Credential $creds -ComputerName $target -ScriptBlock {
    Get-CimInstance -ClassName Win32_Service |
        Select-Object -Property @{n="ServiceName";e={$_.name}},
                                @{n="Status";e={$_.state}},
                                @{n="StartType";e={$_.stertmode}},
                                PathName
} >> $savefile\services.txt
