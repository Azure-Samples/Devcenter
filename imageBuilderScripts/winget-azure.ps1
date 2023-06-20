# Check if winget is installed
if (-not(Get-Command winget -ErrorAction SilentlyContinue)) {
    # Install winget
    Write-Information "Installing winget..."
    $progressPreference = 'silentlyContinue'
    $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    Write-Information "Downloading winget to artifacts directory..."
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage $latestWingetMsixBundle
}

# Install apps

winget install --id 7zip.7zip -e
winget install --id Adobe.AdobeAcrobatReaderDC -e
winget install --id Microsoft.AzCopy -e
winget install --id Microsoft.AzureCLI -e
winget install --id Microsoft.AzureIoTInstaller -e
winget install --id Docker.DockerDesktop -e
winget install --id Mozilla.Firefox -e
winget install --id Flux.Flux -e
winget install --id GitHub.cli -e
winget install --id Git.Git -e
winget install --id GitHub.GitHubDesktop -e
winget install --id Google.Chrome -e
winget install --id stedolan.jq -e
winget install --id Kubernetes.kubectl -e
winget install --id Kubernetes.Helm -e
winget install --id dotPDNLLC.Paint.NET -e
winget install --id Pulumi.Pulumi -e
winget install --id Microsoft.PowerShell -e
winget install --id ServiceBusExplorer.ServiceBusExplorer -e
winget install --id HashiCorp.Terraform -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Git.Git -e