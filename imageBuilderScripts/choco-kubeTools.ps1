If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco install azcopy -y
choco install vscode -y
choco install pwsh -y
choco install azure-cli -y
choco install kubernetes-cli -y
choco install git -y
choco install kubernetes-helm -y