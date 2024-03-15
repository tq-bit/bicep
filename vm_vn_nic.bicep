param location string = resourceGroup().location

param virtualNetworks array = [
  {
    id: 'az104-configure-network-peering-01-vn01'
    name: 'MarketingVnet'
    prefix: '10.2.0.0/16'
    subnets: [
      {
        id: 'az104-configure-network-peering-01-vn01-sub01'
        name: 'MarketingAppsSubnet'
        prefix: '10.2.0.0/24'
      }
    ]
  }
  {
    id: 'az104-configure-network-peering-01-vn02'
    name: 'ResearchVnet'
    prefix: '10.3.0.0/16'
    subnets: [
      {
        id: 'az104-configure-network-peering-01-vn02-sub01'
        name: 'ResearchAppsSubnet'
        prefix: '10.3.0.0/24'
      }
    ]
  }
  {
    id: 'az104-configure-network-peering-01-vn03'
    name: 'SalesVnet'
    prefix: '10.4.0.0/16'
    subnets: [
      {
        id: 'az104-configure-network-peering-01-vn03-sub01'
        name: 'SalesAppsSubnet'
        prefix: '10.4.0.0/24'
      }
    ]
  }
]

param virtualMachines array = [
  {
    name: 'az104-configure-network-peering-01-vm01'
    adminUsername: 'azureuser'
    adminPassword: '321@erurA!bcs'
    subnetDestination: 'MarketingAppsSubnet'
  }
  {
    name: 'az104-configure-network-peering-01-vm02'
    adminUsername: 'azureuser'
    adminPassword: '321@erurA!bcs'
    subnetDestination: 'ResearchAppsSubnet'
  }
  {
    name: 'az104-configure-network-peering-01-vm03'
    adminUsername: 'azureuser'
    adminPassword: '321@erurA!bcs'
    subnetDestination: 'SalesAppsSubnet'
  }
]

// param virtualMachineNics array = [
//   'az104-configure-network-peering-01-vm01-nic01'
//   'az104-configure-network-peering-01-vm02-nic01'
//   'az104-configure-network-peering-01-vm03-nic01'
// ]

resource VirtualNetworks 'Microsoft.Network/virtualNetworks@2023-09-01' = [
  for vnet in virtualNetworks: {
    name: vnet.name
    location: location
    properties: {
      addressSpace: {
        addressPrefixes: [vnet.prefix]
      }
      subnets: [
        for subnet in vnet.subnets: {
          name: subnet.name
          properties: {
            addressPrefix: subnet.prefix
            serviceEndpoints: []
            delegations: []
            privateEndpointNetworkPolicies: 'Disabled'
            privateLinkServiceNetworkPolicies: 'Enabled'
          }
          type: 'Microsoft.Network/virtualNetworks/subnets'
        }
      ]
    }
  }
]

resource VirtualMachinePublicIps 'Microsoft.Network/publicIPAddresses@2023-09-01' = [
  for (vm, i) in virtualMachines: {
    name: '${vm.name}_ip'
    location: location
    properties: {
      publicIPAllocationMethod: 'Dynamic'
    }
  }
]

resource VirtualMachineNics 'Microsoft.Network/networkInterfaces@2023-09-01' = [
  for (vm, i) in virtualMachines: {
    name: '${vm.name}_nic01'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig01'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: VirtualNetworks[i].properties.subnets[0].id
            }
            publicIPAddress: {
              id: VirtualMachinePublicIps[i].id
              properties: {
                deleteOption: 'Detach'
              }
            }
          }
        }
      ]
      nicType: 'Standard'
    }
  }
]

resource VirtualMachines 'Microsoft.Compute/virtualMachines@2023-09-01' = [
  for (vm, i) in virtualMachines: {
    dependsOn: VirtualMachineNics
    name: vm.name
    location: location
    properties: {
      hardwareProfile: {
        vmSize: 'Standard_B1ls'
      }
      additionalCapabilities: {
        hibernationEnabled: false
      }
      storageProfile: {
        imageReference: {
          publisher: 'canonical'
          offer: '0001-com-ubuntu-server-focal'
          sku: '20_04-lts-gen2'
          version: 'latest'
        }
        osDisk: {
          osType: 'Linux'
          name: '${vm.name}_OsDisk_1'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
          deleteOption: 'Delete'
          diskSizeGB: 30
        }
        dataDisks: []
        diskControllerType: 'SCSI'
      }
      osProfile: {
        computerName: vm.name
        adminUsername: vm.adminUsername
        adminPassword: vm.adminPassword
        linuxConfiguration: {
          disablePasswordAuthentication: false
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'AutomaticByPlatform'
            automaticByPlatformSettings: {
              rebootSetting: 'IfRequired'
              bypassPlatformSafetyChecksOnUserSchedule: false
            }
            assessmentMode: 'ImageDefault'
          }
          enableVMAgentPlatformUpdates: false
        }
        secrets: []
        allowExtensionOperations: true
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: VirtualMachineNics[i].id
            properties: {
              deleteOption: 'Detach'
            }
          }
        ]
      }
    }
  }
]
