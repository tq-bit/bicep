param location string = resourceGroup().location
param locationMongo string = 'westeurope'

module Mongo 'mongo.bicep' = {
  name: 'Mongo'
  params: {
    location: locationMongo
    administratorPassword: 'tibQt123!@'
  }
}

module Storage 'storage.bicep' = {
  name: 'Storage'
  params: {
    location: location
  }
}

module WebApplication 'webservice.bicep' = {
  name: 'WebApplication'
  params: {
    location: location
  }
}
