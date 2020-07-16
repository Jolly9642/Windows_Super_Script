# Description:
# This Script removes the following: bloatware apps, tiles in the start menu, and oneDrive.
# It also can set the time zone, power configuration, DNS settings, and download firefox, chrome, Adobe flash and reader. 
# It installs Ublock on firefox and chrome. It just needs to be activated.
# By default this script will set your computer to performance mode. It disables Hybrid sleep, and hibernaton. 

# This is the start of variables that will be applied when this script is run as administrator.

# This will set your time zone to whatever you want it to be.
$timeZone = "Central Standard Time"

# This will specify when you want your monitors to shutoff. 15 is equal to 15 minutes.
$sleepTime = 15

# This will set the DNS. You must know the DNS ip and the name of the adapter you'll be changing.
# If you want this to be default leave adapter name blank and it will error out.
$DNSip = 1.1.1.1
$adapterName = ""

#This command will show all apps in case you need to add more to the list to remove. 
#Get-AppxPackage -AllUsers

#This command removes app
#Get-AppxPackage Microsoft.Paint3D | Remove-AppxPackage

#Alternate way to see everything installed.
#DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename

#Alternate way to remove apps.
#DISM /Online /Remove-ProvisionedAppxPackage /PackageName:PACKAGENAME

#*******************************BEGINNING OF THE SCRIPT********************************************

echo "Uninstalling default apps"
$apps = @(

    # default Windows 10 apps
	
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingFinance"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTravel"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.Reader"
    "Microsoft.SkypeApp"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.WindowsReadingList"
    "Microsoft.XboxApp"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxGameOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MinecraftUWP"
    "*xbox*"
    "*feedback*"
	"*zune*"
	"*connectivitystore*"
	"*oneconnect*"
	"*commsphone*"
	"*windowsphone*"
	"*phone*"
	"*sway*"
	"*3d*"
    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    # non-Microsoft
    "E046963F.LenovoCompanion_4.27.32.0_neutral_~_k1h2ywk1493x8"
    "E046963F.LenovoCompanion"
    "9E2F88E3.Twitter"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
	"*FarmHeroesSaga*"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "*bubblewitch*"
	"*empires*"
	"*candycrush*"
	"*minecraft*"
	"*disney*"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"
	
)

foreach ($app in $apps) {
    echo "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

}

#THIS IS FOR DELETING THE LENOVO BLOATWARE
Get-AppxPackage E046963F.LenovoCompanion | Remove-AppxPackage
Get-AppxPackage Microsoft.MixedReality.Portal | Remove-AppxPackage

echo "end of removing unwanted software********************************************"
echo "Setting time zone to Central Standard Time!+++++++++++++++++++++++++++++++++++"
tzutil /s $timeZone
echo "end of time zone config********************************************"

echo "Updating DNS Settings++++++++++++++++++++++++++++++++++++"
#The code below this is for setting the DNS settings for mass deployments.

Set-DNSClientServerAddress -Addresses {$DNSip} $adapterName

echo "End of DNS Update********************************************"

echo "Initializing power setting configuration!+++++++++++++++++++"
Try {
        $HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
        $CurrPlan = $(powercfg -getactivescheme).split()[3]
        if ($CurrPlan -ne $HighPerf) {powercfg -setactive $HighPerf
		echo "Power Setting set to High Performance!"}
    } Catch {
        Write-Warning -Message "Unable to set power plan to high performance"
    }

powercfg /hibernate off

echo "Hybrid hibernation is turned off!********************************************"

powercfg /x -hibernate-timeout-ac 0

powercfg /x -hibernate-timeout-dc 0

powercfg /x -disk-timeout-ac 0

powercfg /x -disk-timeout-dc 0

powercfg /x -monitor-timeout-ac $sleepTime

powercfg /x -monitor-timeout-dc $sleepTime

Powercfg /x -standby-timeout-ac 0

powercfg /x -standby-timeout-dc 0

echo "end of power setting configuration ********************************************"

#Delete layout file if it already exists

If(Test-Path C:\Windows\StartLayout.xml)
{
    Remove-Item C:\Windows\StartLayout.xml
}

#Creates the blank layout file

echo "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> C:\Windows\StartLayout.xml
echo "  <LayoutOptions StartTileGroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "  <DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "    <StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "      <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "    </StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "  </DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "</LayoutModificationTemplate>" >> C:\Windows\StartLayout.xml

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level

foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value "C:\Windows\StartLayout.xml"
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer and delete the layout file
Stop-Process -name explorer
Remove-Item C:\Windows\StartLayout.xml
Start-Sleep -s 5

echo "End of Unpinning script********************************************"

echo "Initializing installation of chocolatey+++++++++++++++++++"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
echo "waiting for Chocolatey to install..."
Start-Sleep -s 5
echo "installing Adobe reader/flash, firefox, chrome, and java!+++++++++++++++++++
Check Chocolatey.org if you want to look into other programs to add to this script."
choco install adobereader -y
choco install flashplayerplugin -y
choco install googlechrome -y
choco install firefox -y
choco install jre8 -y
choco install ublockorigin-chrome -y
choco install ublockorigin-firefox -y

echo "making Scripts folder and files for Chocolatey updates********************************************"
mkdir C:\Scripts
New-Item C:\Scripts\choco-update.ps1
Add-Content C:\Scripts\choco-update.ps1 "choco upgrade all -y --log-file=C:\Scripts\choco-upgrade.log"
New-Item C:\Scripts\choco-upgrade.log

echo "Creating task to update chocolatey apps at 10PM every day"

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NonInteractive -NoLogo -NoProfile -File 'C:\Choco-Update.ps1'"
$Trigger = New-ScheduledTaskTrigger -Daily -At 10pm
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'ChocoUpdate' -InputObject $Task

echo "installation of chocolatey and needed apps finished!********************************************"

echo "OneDrive removal scripts initializing+++++++++++++++++++++"
echo "73 OneDrive process and explorer"
taskkill.exe /F /IM "OneDrive.exe"
taskkill.exe /F /IM "explorer.exe"

echo "Remove OneDrive"
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

echo "Disable OneDrive via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
sp "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

echo "Removing OneDrive leftovers trash"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

echo "Remove Onedrive from explorer sidebar"
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
Remove-PSDrive "HKCR"

echo "Removing run option for new users"
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

echo "Removing startmenu junk entry"
rm -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

echo "Restarting explorer..."
start "explorer.exe"

echo "Wait for EX reload.."
sleep 15

echo "Removing additional OneDrive leftovers"
foreach ($item in (ls "$env:WinDir\WinSxS\*onedrive*")) {
    Takeown-Folder $item.FullName
    rm -Recurse -Force $item.FullName
}
echo "OneDrive removal complete********************************************"

echo "done"

