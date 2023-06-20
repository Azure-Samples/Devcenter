# Install a pre-release version of Winget
$progressPreference = 'silentlyContinue'
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://github.com/microsoft/winget-cli/releases/1.6.1573-preview).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }

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

# Install apps

winget install --id 7zip.7zip -e --accept-source-agreements 
winget install --id Adobe.Acrobat.Reader.64-bit -e --accept-source-agreements 
winget install --id Microsoft.Azure.AZCopy.10 -e --accept-source-agreements
winget install --id Microsoft.AzureCLI -e --accept-source-agreements
winget install --id Docker.DockerDesktop -e --accept-source-agreements
winget install --id Mozilla.Firefox -e --accept-source-agreements
winget install --id GitHub.cli -e --accept-source-agreements
winget install --id Git.Git -e --accept-source-agreements
winget install --id GitHub.GitHubDesktop -e --accept-source-agreements
winget install --id Google.Chrome -e --accept-source-agreements
winget install --id stedolan.jq -e --accept-source-agreements
winget install --id Kubernetes.kubectl -e --accept-source-agreements
winget install --id Kubernetes.Helm -e --accept-source-agreements
winget install --id dotPDNLLC.Paint.NET -e --accept-source-agreements
winget install --id Pulumi.Pulumi -e --accept-source-agreements
winget install --id Microsoft.PowerShell -e --accept-source-agreements
winget install --id ServiceBusExplorer.ServiceBusExplorer -e --accept-source-agreements
winget install --id HashiCorp.Terraform -e --accept-source-agreements
winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements
winget install --id Microsoft.Azure.IoTExplorer -e --accept-source-agreements