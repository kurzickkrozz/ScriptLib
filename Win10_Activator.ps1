#Requires -RunAsAdministrator
# Set title and clear screen
$host.UI.RawUI.WindowTitle = "Win10 Activator"
Clear-Host

# Display information
Write-Host "************************************"
Write-Host "Your friend: TunnelRat"
Write-Host ""
Write-Host "Supported products:"
Write-Host "- Windows 10 Home"
Write-Host "- Windows 10 Professional"
Write-Host "- Windows 10 Enterprise, Enterprise LTSB"
Write-Host "- Windows 10 Education"
Write-Host ""
Write-Host "************************************"
Write-Host "Windows 10 activation..."

# Function to run slmgr.vbs commands
function Invoke-SlmgrCommand {
    param([string]$args)
    $output = cscript //nologo c:\windows\system32\slmgr.vbs $args 2>&1
    return $output
}

# Array of product keys
$productKeys = @(
    "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99",
    "3KHY7-WNT83-DGQKR-F7HPR-844BM",
    "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH",
    "PVMJN-6DFY6-9CCP6-7BKTT-D3WVR",
    "W269N-WFGWX-YVC9B-4J6C9-T83GX",
    "MH37W-N47XK-V7XM9-C7227-GCQG9",
    "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2",
    "2WH4N-8QGBV-H22JP-CT43Q-MDWWJ",
    "NPPR9-FWDCX-D2C8J-H872K-2YT43",
    "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4",
    "WNMTR-4C88C-JK8YV-HQ7T2-76DF9",
    "2F77B-TNFGY-69QQF-B8YKP-D69TJ"
)

# Install product keys
foreach ($key in $productKeys) {
    Invoke-SlmgrCommand "/ipk $key" | Out-Null
}

Write-Host "************************************"
Write-Host ""

# KMS servers
$kmsServers = @("kms.ddns.net", "kms.shuax.com", "AlwaysSmile.uk.to")

# Try activation with each KMS server
foreach ($server in $kmsServers) {
    Write-Host "Attempting activation with server: $server"
    Invoke-SlmgrCommand "/skms $server" | Out-Null
    $result = Invoke-SlmgrCommand "/ato"
    
    if ($result -match "successfully") {
        Write-Host "Activation successful!"
        $restart = Read-Host "Do you want to restart your PC now? (Y/N)"
        if ($restart -eq "Y") {
            Restart-Computer -Force
        }
        exit
    } else {
        Write-Host "Activation failed. Trying next server..."
    }
}

Write-Host "All activation attempts failed."
