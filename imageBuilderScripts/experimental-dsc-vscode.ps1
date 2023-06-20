# This script will install VS Code from winget
# Please note that this script requires winget features that are not yet available in the current stable release. 
# Refer to the following Microsoft Learn page to find out how to configure winget experimental 
# features: https://learn.microsoft.com/en-us/windows/package-manager/configuration/#enable-the-winget-configuration-experimental-configuration-preview-feature

# Install a pre-release version of Winget
$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/Pre-release).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://github.com/microsoft/winget-cli/releases/1.6.1573-preview).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }

$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
#Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage $latestWingetMsixBundle

Write-Information "Installing winget..."
$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = "https://github.com/microsoft/winget-cli/releases/download/v1.6.1573-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
Write-Information "Downloading winget to artifacts directory..."
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
#Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage $latestWingetMsixBundle

# Enable experimental features in winget settings file (settings.json)

$path = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$content = @"
{
    "`$schema": "https://aka.ms/winget-settings.schema.json",

    // For documentation on these settings, see: https://aka.ms/winget-settings
    // "source": {
    //    "autoUpdateIntervalInMinutes": 5
    // },
	"experimentalFeatures": {
       "configuration": true
   }
}
"@
$content | Set-Content $path

winget configure -f .\vscode.dsc.yaml --accept-configuration-agreements