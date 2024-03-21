# Create a reciprocal connection between MarketingVnet and ResearchVnet

# From MarketingVnet to ResearchVnet
az network vnet peering create \
  --name MarketingVnetToResearchVnet \
  --remote-vnet ResearchVnet \
  --resource-group vm-deployment \
  --vnet-name MarketingVnet \
  --allow-vnet-access

# From ResearchVnet to MarketingVnet
az network vnet peering create \
  --name ResearchVnetToMarketingVnet \
  --remote-vnet MarketingVnet \
  --resource-group vm-deployment \
  --vnet-name ResearchVnet \
  --allow-vnet-access

# Check access from MarketingVnet to other networks
az network vnet peering list \
  --resource-group vm-deployment \
  --vnet-name MarketingVnet \
  --query "[].{Name:name, Resource:resourceGroup, AllowVnetAccess:allowVirtualNetworkAccess}" \
  -o table

# Check the routing table for the NIC from VM01
az network nic show-effective-route-table \
  --resource-group vm-deployment \
  --name az104-configure-network-peering-01-vm01_nic01 \
  -o table
