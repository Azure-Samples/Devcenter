param nameseed string = 'dbox'
param location string = resourceGroup().location

@description('For a multi region scenarios, new vnets and pools will be created for the project')
param extraLocations array = []

param devcenterName string
param projectTeamName string = 'developers'

var scheduleProperties = {
  frequency: 'Daily'
  state: 'Enabled'
  type: 'StopDevBox'
  timeZone: 'America/Los_Angeles'
  time: '18:00'
}

@description('All locations, in one array')
var allLocations = concat([location],extraLocations)

resource dc 'Microsoft.DevCenter/devcenters@2022-11-11-preview' existing = {
  name: devcenterName
}

resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' existing = {
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

resource win11ProjectPool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = [ for (loc, i) in allLocations: {
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

resource vsProjectPool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' =  [ for (loc, i) in allLocations: {
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
resource scheduleStop 'Microsoft.DevCenter/projects/pools/schedules@2023-01-01-preview' =  [ for (loc, i) in allLocations: {
  name: '${projectTeamName}/${projectTeamName}-${i % 2 == 0 ? 'win11plain' : 'vs2022'}-${loc}/default'
  properties: scheduleProperties
}]
