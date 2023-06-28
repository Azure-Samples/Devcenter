param nameseed string = 'dbox'
param location string = resourceGroup().location
param devcenterName string

param subnetName string = 'sn-devpools'
param vnetAddress string = '10.0.0.0/16'
param subnetAddress string = '10.0.0.0/24'

@description('The name of a new resource group that will be created to store some Networking resources (like NICs) in')
param networkingResourceGroupName string = '${resourceGroup().name}-networking-${location}'

resource dc 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devcenterName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'vnet-${nameseed}-${location}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddress
        }
      }
    ]
  }
}

resource networkconnection 'Microsoft.DevCenter/networkConnections@2023-04-01' = {
  name: 'con-${nameseed}-${location}'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: '${virtualNetwork.id}/subnets/${subnetName}'
    networkingResourceGroupName: networkingResourceGroupName
  }
}

resource attachedNetwork 'Microsoft.DevCenter/devcenters/attachednetworks@2023-04-01' = {
  name: 'dcon-${nameseed}-${location}'
  parent: dc
  properties: {
    networkConnectionId: networkconnection.id
  }
}

output networkConnectionName string = networkconnection.name
output networkConnectionId string = networkconnection.id
output attachedNetworkName string = attachedNetwork.name
