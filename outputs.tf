###############################################################################
# outputs.tf — Landing Zone
#
# Exposes key resource attributes after a successful apply.
# These values can be consumed by downstream Terraform configurations via
# remote state or passed to other modules.
###############################################################################

output "resource_group_name" {
  description = "Name of the landing-zone resource group."
  value       = azurerm_resource_group.lz.name
}

output "resource_group_id" {
  description = "Resource ID of the landing-zone resource group."
  value       = azurerm_resource_group.lz.id
}

output "resource_group_location" {
  description = "Azure region of the landing-zone resource group."
  value       = azurerm_resource_group.lz.location
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.lz.name
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.lz.id
}

output "vnet_address_space" {
  description = "Address space(s) assigned to the Virtual Network."
  value       = azurerm_virtual_network.lz.address_space
}

output "subnet_name" {
  description = "Name of the subnet."
  value       = azurerm_subnet.lz.name
}

output "subnet_id" {
  description = "Resource ID of the subnet."
  value       = azurerm_subnet.lz.id
}

output "subnet_address_prefix" {
  description = "CIDR prefix of the subnet."
  value       = azurerm_subnet.lz.address_prefixes[0]
}

output "nsg_name" {
  description = "Name of the Network Security Group."
  value       = azurerm_network_security_group.lz.name
}

output "nsg_id" {
  description = "Resource ID of the Network Security Group."
  value       = azurerm_network_security_group.lz.id
}

output "nsg_subnet_association_id" {
  description = "Resource ID of the NSG-to-Subnet association."
  value       = azurerm_subnet_network_security_group_association.lz.id
}

output "landing_zone_summary" {
  description = "High-level summary of the deployed landing-zone resources."
  value = {
    resource_group        = azurerm_resource_group.lz.name
    location              = azurerm_resource_group.lz.location
    vnet                  = azurerm_virtual_network.lz.name
    vnet_address_space    = azurerm_virtual_network.lz.address_space
    subnet                = azurerm_subnet.lz.name
    subnet_address_prefix = azurerm_subnet.lz.address_prefixes[0]
    nsg                   = azurerm_network_security_group.lz.name
    nsg_inbound_rules     = length(var.nsg_inbound_rules)
    nsg_outbound_rules    = length(var.nsg_outbound_rules)
    environment           = var.environment
    managed_by            = "terraform"
  }
}
