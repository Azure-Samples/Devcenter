@description('The Azure region where resources in the template should be deployed.')
param location string = resourceGroup().location
param imageName string
param imageSku string
param devcenterName string
param devcenterGalleryName string

@allowed(['ssd_256gb', 'ssd_512gb', 'ssd_1024gb'])
param storage string = 'ssd_256gb'

resource dc 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devcenterName
}

resource dcGallery 'Microsoft.DevCenter/devcenters/galleries@2023-04-01' existing = {
  name: devcenterGalleryName
  parent: dc
}

resource galleryimage 'Microsoft.DevCenter/devcenters/galleries/images@2023-04-01' existing = {
  name: imageName
  parent: dcGallery
}

resource devboxdef 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  name: imageName
  parent: dc
  location: location
  properties: {
    sku: {
      name: imageSku
    }
    imageReference: {
      id: galleryimage.id //the resource-id of a Microsoft.DevCenter Gallery Image
    }
    osStorageType: storage
    hibernateSupport: 'Disabled'
  }
}
output definitionName string = devboxdef.name
