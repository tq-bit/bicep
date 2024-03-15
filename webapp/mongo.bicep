param mongoClusterName string = 'tqbit-mongodb-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param administratorLogin string = 'tqbit'
@secure()
param administratorPassword string

resource MongoCluster 'Microsoft.DocumentDB/mongoClusters@2023-11-15-preview' = {
  name: mongoClusterName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    serverVersion: '6.0'
    nodeGroupSpecs: [
      {
        kind: 'Shard'
        sku: 'Free'
        diskSizeGB: 32
        enableHa: false
        nodeCount: 1
      }
    ]
  }
}

resource MongoClusterFirewallRuleAllowAll 'Microsoft.DocumentDB/mongoClusters/firewallRules@2023-11-15-preview' = {
  parent: MongoCluster
  name: 'AllowAll_2024-2-26-14-53-27'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource MongoClusterFirewallRuleAllowWithinAzureIps 'Microsoft.DocumentDB/mongoClusters/firewallRules@2023-11-15-preview' = {
  parent: MongoCluster
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps_2024-2-26_14-40-30'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

