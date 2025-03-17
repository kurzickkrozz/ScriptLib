#Requires -RunAsAdministrator

<# 
To set execution policy to run scripts, use the following command:

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

To disable/enable firewall, use the following command:

icm -cn <IPAddress> -cr $creds -ScriptBlock {Set-NetFirewallProfile -Name * -Enabled False}
icm -cn <IPAddress> -cr $creds -ScriptBlock {Set-NetFirewallProfile -Name * -Enabled True}

Alternatively, if the target machine has issues with PowerShell and you need to invoke CMD commands:

icm -cn <IPAddress> -cr $creds -ScriptBlock {netsh.exe advfirewall set allprofiles state off}
icm -cn <IPAddress> -cr $creds -ScriptBlock {netsh.exe advfirewall set allprofiles state on}

#>

########################################
# Formatting Functions
function OutputIsGood {
    param (
        $GoodText
    )
    Write-Host -ForegroundColor Green "[+] $GoodText"
}
function OutputIsBad {
    param (
        $BadText
    )
    Write-Host -ForegroundColor Red "[!] $BadText"
}
function OutPutIsNeutral {
    param (
        $NeutralText
    )
    Write-Host -ForegroundColor Yellow "[-] $NeutralText"
}

########################################
# SETUP
$LATFP = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\").LocalAccountTokenFilterPolicy

if ($LATFP -eq 1) {
    OutputIsGood "LocalAccountTokenFilterPolicy is set to 1 -- local accounts CAN access this endpoint remotely."
    } 
elseif ($LATFP -eq 0) {
    OutPutIsBad "LocalAccountTokenFilterPolicy is set to 0 -- local accounts CANNOT access this endpoint remotely."
    }

OutPutIsNeutral "Do you want to change the policy to ALLOW or DENY remote authentication for local accounts?"
    $query = Read-Host -Prompt "Please respond with a (allow), d (deny), or c (cancel)"
    while (($query) -notin "allow", "a", "deny", "d", "cancel", "c") {
        OutPutIsNeutral "Please respond with a (allow), d (deny), or c (cancel)."
        $query = Read-Host }

$currentDirectory = pwd

########################################
# LATFP
function EnableLATFP {
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name LocalAccountTokenFilterPolicy -Value 1 -ErrorAction Stop
        $newvalue = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\").LocalAccountTokenFilterPolicy
        OutputIsGood "LocalAccountTokenFilterPolicy succesfully updated to $newvalue"
    }
    catch [System.Security.SecurityException] {
        OutputIsBad "Error updating LocalAccountTokenFilterPolicy."
        break
    }
}

function DisableLATFP {
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name LocalAccountTokenFilterPolicy -Value 0 -ErrorAction Stop
        $newvalue = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\").LocalAccountTokenFilterPolicy
        OutputIsGood "LocalAccountTokenFilterPolicy succesfully updated to $newvalue"
    }
    catch [System.Security.SecurityException] {
        OutputIsBad "Error updating LocalAccountTokenFilterPolicy."
        break
    }
}

function CancelLATFP {
    OutPutIsNeutral "Not updating LocalAccountTokenFilterPolicy"
}


########################################
# Disable/Restore GPO for SeDenyNetworkLogonRight
$oldpolicy = "$env:windir\system32\SecConfigBackup.inf"
$newpolicy = "$env:windir\system32\NewSecPolicy.inf"
function OpenGPOPolicy {
    try {
        [void](SecEdit.exe /export /cfg $oldpolicy)
    }
    catch {
        OutputIsBad "Could not generate config file."
    }
    try {
        (Get-Content $oldpolicy) -replace '.*SeDenyNetworkLogonRight.*', 'SeDenyNetworkLogonRight =' | Out-File $newpolicy
    }
    catch {
        OutputIsBad "Error parsing $filename"
    }

    #[IO.File]::WriteAllBytes($filename, $bytes)
    OutPutIsNeutral "Updating local group policy to allow remote authentication to this computer."
    SecEdit.exe /configure /db "tempupdate" /cfg $newpolicy
    Remove-Item "tempupdate*"
}

function RestoreGPOPolicy {
    #[IO.File]::WriteAllBytes($filename, $bytes)
    OutPutIsNeutral "Restoring local group policy to default configuration file."
    SecEdit.exe /configure /db "tempupdate" /cfg $oldpolicy
    OutPutIsNeutral "Cleaning up SecEdit files."
    Remove-Item "tempupdate*" -Force
    Remove-Item $oldpolicy -Force
    Remove-Item $newpolicy -Force
    OutPutIsGood "SecEdit files cleaned!"
}

function CancelGPOPolicy {
    OutPutIsNeutral "Not updating local group policy."
}

########################################
# Adapter for WINRM

function ConfigureAdapterPrivate {
    if ((Get-NetConnectionProfile).NetworkCategory -in "Public") {
        OutPutIsNeutral "Network Category is currently set to Public...changing to Private."
        try {
            Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
        }
        catch {
            OutputIsBad "ERROR CHANGING TO PRIVATE."
        }
    }
    else {
        OutputIsGood "Adapter is now set to Private. WinRM should work on the adapter!"
    }
}

function ConfigureAdapterPublic {
    if ((Get-NetConnectionProfile).NetworkCategory -in "Private") {
        OutPutIsNeutral "Network Category is currently set to Private...changing to Public."
        try {
            Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Public
        }
        catch {
            OutputIsBad "ERROR CHANGING TO PUBLIC."
        }
    }
    else {
        OutputIsGood "Adapter now set to Public. WinRM should NOT work on the adapter!"
    }
}

function CancelAdapterPublic {
    OutPutIsNeutral "Not updating network adapter category."
}
########################################
# WINRM Listener

function CreateWinRMListener {
    if ((Get-Service -Name WinRM).StartType -ne "Automatic") {
        OutPutIsNeutral "WinRM not set to start...changing to Automatic."
        try {
            Set-Service -Name WinRM -StartupType Automatic
            OutPutIsNeutral "Service set to Automatic..."
            Start-Service -Name WinRM
            OutputIsGood "WinRM started!"
        }
        catch {
            OutputIsBad "Error setting WINRM service."
        }
        OutPutIsNeutral "Enabling WinrRM HTTP listener..."
        try {
            Set-Location -Path "WSMan:"
            New-Item -Path WSMan:\localhost\Listener -Address * -Transport http -Force
            OutputIsGood "Created WINRM Listener!"
            Set-Location -Path $currentDirectory
        }
        catch {
            OutputIsBad "Error creating WINRM Listener!"
        }
    }
}

function DeleteWinRMListener {
    if ((Get-Service -Name WinRM).StartType -ne "Disabled") {
        OutPutIsNeutral "Disabling WinrRM HTTP listener..."
        try {
            Set-Location -Path "WSMan:"
            Remove-Item -Path "WSMan:\localhost\Listener\Listener*" -Recurse -Force
            OutputIsGood "Deleted WINRM Listener."
            Set-Location -Path $currentDirectory
        }
        catch {
            OutputIsBad "Error deleting WINRM Listener!"
        }
        OutPutIsNeutral "WinRM is still enabled. Disabling now..."
        try {
            Stop-Service -Name WinRM
            OutputIsGood "Stopping WinRM!"
            Set-Service -Name WinRM -StartupType Disabled
            OutPutIsNeutral "Disabling service"
        }
        catch {
            OutputIsBad "Error disabling WINRM service."
        }
    }
}

function CancelWinRMListener {
    OutPutIsNeutral "Quitting WinRM Listener Configurator."
}

########################################
# Firewall Rule

function EnableFirewallRule {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $ip = [Microsoft.VisualBasic.Interaction]::InputBox("Enter an IP address that will have unfettered access through the Firewall:")
    try {
        $rulename = "WinRM_Allow_IP_" + $ip
        [void](New-NetFirewallRule -Action Allow -Direction Inbound -DisplayName $rulename -ErrorAction Stop -Protocol TCP -RemoteAddress $ip) 
        OutputIsGood "Created firewall rule"
    }
    catch {
        OutputIsBad "Failed to create rule"
    }
}

function DisableFirewallRule {
    try {
        [void](Remove-NetFirewallRule -DisplayName "WinRM_Allow_IP_*" -ErrorAction Stop) 
        OutputIsGood "Removed firewall rule."
    }
    catch {
        OutputIsBad "Failed to remove rule."
    }
}


function CancelFirewallRule {
    OutPutIsNeutral "Not updating firewall rules."
}

########################################

if ($query -in "a", "allow") {
    EnableLATFP
    OpenGPOPolicy
    ConfigureAdapterPrivate
    CreateWinRMListener
    EnableFirewallRule
} elseif ($query -in "d", "deny") {
    DeleteWinRMListener
    ConfigureAdapterPublic
    RestoreGPOPolicy
    DisableFirewallRule
    DisableLATFP
} elseif ($query -in "c", "cancel") {
    CancelLATFP
    CancelGPOPolicy
    CancelWinRMListener
    CancelFirewallRule
    Cancel
}