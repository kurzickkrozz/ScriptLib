# Welcome to my Script Library!
### !!Note!!
Be aware of what these scripts do (Essentially, do your own homework). I am not responsible if your system configuration gets messed up because you don't understand what these scripts do or how they work. The scripts in this library are not intended to be suspicious or malicious in any way; however, if they cause system instability (it's probably because you've used them incorrectly), that is not on me. Read the code. Understand what it does. Execute what you need ran.
### !!Note!!
On Windows 10/11, there is a default policy set to not allow scripts to be ran. To circumvent this, open an administrative PowerShell and run the command:
 - ``Set-ExecutionPolicy Bypass``
To lockdown the execution policy when you're done running the script(s), run this similar command in an administrative PowerShell: 
 - ``Set-ExecutionPolicy Default``
   - For Windows 10/11, the policy is ``Restricted``. For Windows Server, the policy is ``RemoteSigned``.

### List of scripts & their descriptions:
- Anti-bloat.ps1
  - Removes bloatware from Windows 10/11 installations (Read script before execution for more options)
- Autorunners.txt
  - Extensive list of Windows Autorun locations
- Baseline.ps1
  - Gathers a system forensic baseline REMOTELY (WinRM must be enabled!)
- CopyDriverFiles_v1.3.ps1
  - Copies Nvidia driver from host machine into selected VM (Hyper-V)
- GPU-P-Partition_Updated.ps1
  - GPU Passthru from host machine to selected VM (Hyper-V)
- Icon Restore.bat
  - Clears IconCache.db and restarts Explorer.exe when application icons break
- MediaOrganizer.ps1
  - Puts all files from a directory into sub-directories with their respective file name (Plex hosters)
- MediaOrganizer.sh
  - Same as MediaOrganizer.ps1, but written in bash for Linux-based systems
- Procs&IP.ps1
  - Pulls list of all running process that have a network connection (See what's talking!)
- Product_Key_Finder.ps1
  - Pulls your current Windows license key
- RDP Port Fixer.ps1
  - Script to change your RDP Port (Testing purposes only! Do not expose RDP to the internet)
- README.md
  - This file that you're reading right now
- Show-MetaData.ps1
  - Pulls ALL metadata from a single file of your choosing (directory version coming soon!)
- TR-MediaFixer.zip
  - Script and .dll to match media file's Filename to its "Title" property (For Plex to properly display it)
- Win10_Activator.bat
  - Activates Win10/11 with Generic Volume License Key (GVLK) against KMS Servers (Useful for VM's that need activation)
- Win10_Activator.ps1
  - Same as its batch script alternative. This is still being worked on. USE THE BATCH SCRIPT AS ADMIN!
- Win11_Menu_Revert.ps1
  - Gives Windows 11 the Windows 10 contextual menu. A MUST HAVE!!
- WinRM-Setup.ps1
  - Configures LATFP, GPO Policy, Net Adapter, Firewall, and creates a WinRM Listener. Cleanup function built-in too.
