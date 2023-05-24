param nameseed string = 'dbox'
param location string = resourceGroup().location
param devcenterName string
param projectTeamName string = 'developers'

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

module networking 'devboxNetworking.bicep' = {
  name: '${deployment().name}-Networking'
  params: {
    devcenterName: dc.name
    location: location
    nameseed: nameseed
  }
}

resource win11ProjectPool 'Microsoft.DevCenter/projects/pools@2022-11-11-preview' = {
  name: '${projectTeamName}-win11plain'
  location: location
  parent: project
  properties: {
    devBoxDefinitionName: win11plain.outputs.definitionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networking.outputs.attachedNetworkName
  }
  
  
  resource scheduleStop 'schedules' = {
    name: 'default' //Currently we only support one schedule for a pool and the schedule name can only be 'default'"
    properties: {
      frequency: 'Daily'
      state: 'Enabled'
      type: 'StopDevBox'
      timeZone: 'America/Los_Angeles'
      time: '18:00'
    }
  }
}

resource vsProjectPool 'Microsoft.DevCenter/projects/pools@2022-11-11-preview' = {
  name: '${projectTeamName}-vs2022'
  location: location
  parent: project
  properties: {
    devBoxDefinitionName: vs2022.outputs.definitionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: networking.outputs.attachedNetworkName
  }
  
  
  resource scheduleStop 'schedules' = {
    name: 'default' //Currently we only support one schedule for a pool and the schedule name can only be 'default'"
    properties: {
      frequency: 'Daily'
      state: 'Enabled'
      type: 'StopDevBox'
      timeZone: 'America/Los_Angeles'
      time: '18:00'
    }
  }
}
