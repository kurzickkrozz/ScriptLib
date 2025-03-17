Write-Output "Uninstalling default apps"
$apps = @(
	# Apps below will be unstinalled! Comment them out with a "#" if you want to keep them.
	"Clipchamp.Clipchamp"
	"Microsoft.3DBuilder"
	"Microsoft.549981C3F5F10"   #Cortana app
	"Microsoft.BingFinance"
	"Microsoft.BingFoodAndDrink"
	"Microsoft.BingHealthAndFitness"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingTranslator"
	"Microsoft.BingTravel"
	"Microsoft.BingWeather"
	"Microsoft.FreshPaint"
	"Microsoft.Getstarted"   # Cannot be uninstalled in Windows 11
	"Microsoft.Messaging"
	"Microsoft.Microsoft3DViewer"
	"Microsoft.MicrosoftJournal"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftPowerBIForWindows"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.MinecraftUWP"
	"Microsoft.MixedReality.Portal"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.News"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.OneConnect"
	"Microsoft.PowerBIForWindows"
	"Microsoft.Print3D"
	"Microsoft.SkypeApp"
	"Microsoft.Todos"
	"Microsoft.Wallet"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsReadingList"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.XboxApp"   # Old Xbox Console Companion App, no longer supported
	"Microsoft.YourPhone"
	"Microsoft.ZuneVideo"
	"MicrosoftCorporationII.MicrosoftFamily"   # Family Safety App
	"MicrosoftCorporationII.QuickAssist"
	"MicrosoftTeams"   # Old MS Teams personal (MS Store)
	"MSTeams"   # New MS Teams app
	# ----------------------------------------------
	# Apps below this line are not Microsoft related
	# ----------------------------------------------
	"ACGMediaPlayer"
	"ActiproSoftwareLLC"
	"AdobeSystemsIncorporated.AdobePhotoshopExpress"
	"Amazon.com.Amazon"
	"AmazonVideo.PrimeVideo"
	"Asphalt8Airborne"
	"AutodeskSketchBook"
	"CaesarsSlotsFreeCasino"
	"COOKINGFEVER"
	"CyberLinkMediaSuiteEssentials"
	"DisneyMagicKingdoms"
	"Disney"
	"DrawboardPDF"
	"Duolingo-LearnLanguagesforFree"
	"EclipseManager"
	"Facebook"
	"FarmVille2CountryEscape"
	"fitbit"
	"Flipboard"
	"HiddenCity"
	"HULULLC.HULUPLUS"
	"iHeartRadio"
	"Instagram"
	"king.com.BubbleWitch3Saga"
	"king.com.CandyCrushSaga"
	"king.com.CandyCrushSodaSaga"
	"LinkedInforWindows"
	"MarchofEmpires"
	"Netflix"
	"NYTCrossword"
	"OneCalendar"
	"PandoraMediaInc"
	"PhototasticCollage"
	"PicsArt-PhotoStudio"
	"Plex"
	"PolarrPhotoEditorAcademicEdition"
	"Royal Revolt"
	"Shazam"
	"Sidia.LiveWallpaper"
	"SlingTV"
	"Spotify"
	"TikTok"
	"TuneInRadio"
	"Twitter"
	"Viber"
	"WinZipUniversal"
	"Wunderlist"
	"XING"
	# ----------------------------------------------------------------------
	# Apps below this line will NOT be uninstalled unless you uncomment them
	# ----------------------------------------------------------------------
	#"Microsoft.BingSearch"					# Web Search from Microsoft Bing (Integrates into Windows Search)
	#"Microsoft.Copilot"					# New Windows Copilot app
	#"Microsoft.Edge"						# Edge browser (Can only be uninstalled in European Economic Area)
	#"Microsoft.GamingApp"					# Modern Xbox Gaming App, required for installing some PC games
	#"Microsoft.GetHelp"					# Required for some Windows 11 Troubleshooters
	#"Microsoft.MSPaint"					# Paint 3D
	#"Microsoft.OneDrive"					# OneDrive consumer
	#"Microsoft.OutlookForWindows"			# New mail app: Outlook for Windows
	#"Microsoft.People"						# Required for & included with Mail & Calendar
	#"Microsoft.Paint"						# Classic Paint
	#"Microsoft.PowerAutomateDesktop"
	#"Microsoft.RemoteDesktop"
	#"Microsoft.ScreenSketch"				# Snipping Tool
	#"Microsoft.Whiteboard"					# Only preinstalled on devices with touchscreen and/or pen support
	#"Microsoft.Windows.DevHome"
	#"Microsoft.Windows.Photos"
	#"Microsoft.WindowsCalculator"
	#"Microsoft.WindowsCamera"
	#"Microsoft.windowscommunicationsapps"    # Mail & Calendar
	#"Microsoft.WindowsNotepad"
	#"Microsoft.WindowsStore"				# Microsoft Store, WARNING: This app cannot be reinstalled!
	#"Microsoft.WindowsTerminal"			# New default terminal app in windows 11
	#"Microsoft.Xbox.TCUI"					# UI Framework, REQUIRED for MS store, photos and certain games
	#"Microsoft.XboxGameOverlay"              # Game overlay, required/useful for some games
	#"Microsoft.XboxGamingOverlay"            # Game overlay, required/useful for some games
	#"Microsoft.XboxIdentityProvider"		# Xbox sign-in framework, required for some games
	#"Microsoft.XboxSpeechToTextOverlay"	# Required for some games, WARNING: This app cannot be reinstalled!
	#"Microsoft.ZuneMusic"					# Modern Media Player
	#"MicrosoftWindows.CrossDevice"			# Phone integration within File Explorer, Camera and more
)

$appxprovisionedpackage = Get-AppxProvisionedPackage -Online

foreach ($app in $apps) {
	Write-Output "Trying to remove $app"
	
	Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
	
	($appxprovisionedpackage).Where( {$_.DisplayName -EQ $app}) | 
		Remove-AppxProvisionedPackage -Online
}