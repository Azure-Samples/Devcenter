# This script will install kube tools from winget
# Please note that this script requires winget features that are not yet available in the current stable release. 
# Refer to the following Microsoft Learn page to find out how to configure winget experimental 
# features: https://learn.microsoft.com/en-us/windows/package-manager/configuration/#enable-the-winget-configuration-experimental-configuration-preview-feature

winget configure .\kube-tools.dsc.yaml