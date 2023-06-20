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

winget install --id Microsoft.AzCopy -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Microsoft.PowerShell -e
winget install --id Microsoft.AzureCLI -e
winget install --id Kubernetes.kubectl -e
winget install --id Git.Git -e
winget install --id Kubernetes.Helm -e