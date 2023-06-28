param nameseed string = 'dbox'
param location string = resourceGroup().location

@description('For a multi region scenarios, new vnets and pools will be created for the project')
param extraLocations array = []

@description('The name of the existing DevCenter')
param devcenterName string

@description('The name of the project team')
param projectTeamName string = 'developers'

@description('The time to shutdown the devbox. This is in the timezone of the region where the devbox is located. HH:mm format.')
param shutdownTime string = '18:00'

@description('A list of Azure locations and their time zone. From: https://github.com/Gordonby/Snippets/tree/master/Iana-Time-Regions')
var regionTimeZones = loadJsonContent('azure-region-lookup.json')

@description('All locations, in one array')
var allLocations = concat([location],extraLocations)

resource dc 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devcenterName
}

resource project 'Microsoft.DevCenter/projects@2023-04-01' existing = {
  name: projectTeamName
}

module win11plain 'devboxdef.bicep' = {
  name: '${deployment().name}-DevboxDef-win11'
  params: {
    devcenterName: dc.name
    location: location
  }
}

module vs2022 'devboxdef.bicep' = {
  name: '${deployment().name}-DevboxDef-vs2022'
  params: {
    devcenterName: devcenterName
    location: location
    image: 'vs2022win11m365'
    storage: 'ssd_256gb'
  }
}

module networkingLocations 'devboxNetworking.bicep' = [for (loc, i) in allLocations: {
  name: '${deployment().name}-Networking-${loc}'
  params: {
    devcenterName: dc.name
    location: loc
    nameseed: nameseed
  }
}]

resource win11ProjectPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = [ for (loc, i) in allLocations: {
  name: '${projectTeamName}-win11plain-${loc}'
  location: location
  parent: project
  properties: {
    devBoxDefinitionName: win11plain.outputs.definitionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkingLocations[i].outputs.attachedNetworkName
  }
}]

resource vsProjectPool 'Microsoft.DevCenter/projects/pools@2023-04-01' =  [ for (loc, i) in allLocations: {
  name: '${projectTeamName}-vs2022-${loc}'
  location: location
  parent: project
  properties: {
    devBoxDefinitionName: vs2022.outputs.definitionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networkingLocations[i].outputs.attachedNetworkName
  }
}]

@description('This loop expression might look complex, but it is simply just creating a schedule for every pool in every region')
resource scheduleStop 'Microsoft.DevCenter/projects/pools/schedules@2023-04-01' =  [ for (loc, i) in allLocations: {
  name: '${projectTeamName}/${projectTeamName}-${i % 2 == 0 ? 'win11plain' : 'vs2022'}-${loc}/default'
  properties: {
    frequency: 'Daily'
    state: 'Enabled'
    type: 'StopDevBox'
    timeZone: regionTimeZones[loc]
    time: shutdownTime
  }
}]
