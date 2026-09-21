###############################################################################
# main.tf — Landing Zone
#
# Provisions the core networking landing-zone resources:
#   1. Resource Group
#   2. Virtual Network (VNet)
#   3. Subnet
#   4. Network Security Group (NSG)  — with configurable inbound/outbound rules
#   5. NSG-to-Subnet association
#
# All names follow the Microsoft Cloud Adoption Framework abbreviation guide.
# No values (subscription IDs, CIDRs, credentials, etc.) are hardcoded.
###############################################################################

###############################################################################
# Locals — centralised naming and tagging
###############################################################################

locals {
  # -------------------------------------------------------------------------
  # Resource names — Microsoft CAF abbreviations
  #   rg-   Resource Group
  #   vnet- Virtual Network
  #   snet- Subnet
  #   nsg-  Network Security Group
  # -------------------------------------------------------------------------
  name_suffix = "${var.prefix}-${var.environment}"

  resource_group_name = "rg-${local.name_suffix}"
  vnet_name           = "vnet-${local.name_suffix}"
  subnet_name         = "snet-${local.name_suffix}"
  nsg_name            = "nsg-${local.name_suffix}"

  # -------------------------------------------------------------------------
  # Standard tags merged with caller-supplied tags
  # -------------------------------------------------------------------------
  standard_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "landing-zone"
  }

  tags = merge(local.standard_tags, var.tags)
}

###############################################################################
# 1. Resource Group
###############################################################################

resource "azurerm_resource_group" "lz" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

###############################################################################
# 2. Virtual Network
###############################################################################

resource "azurerm_virtual_network" "lz" {
  name                = local.vnet_name
  location            = azurerm_resource_group.lz.location
  resource_group_name = azurerm_resource_group.lz.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

###############################################################################
# 3. Subnet
###############################################################################

resource "azurerm_subnet" "lz" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.lz.name
  virtual_network_name = azurerm_virtual_network.lz.name
  address_prefixes     = [var.subnet_address_prefix]
}

###############################################################################
# 4. Network Security Group
###############################################################################

resource "azurerm_network_security_group" "lz" {
  name                = local.nsg_name
  location            = azurerm_resource_group.lz.location
  resource_group_name = azurerm_resource_group.lz.name
  tags                = local.tags

  # -------------------------------------------------------------------------
  # Inbound rules — driven entirely by var.nsg_inbound_rules
  # -------------------------------------------------------------------------
  dynamic "security_rule" {
    for_each = var.nsg_inbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  # -------------------------------------------------------------------------
  # Outbound rules — driven entirely by var.nsg_outbound_rules
  # -------------------------------------------------------------------------
  dynamic "security_rule" {
    for_each = var.nsg_outbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Outbound"
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

###############################################################################
# 5. NSG-to-Subnet association
###############################################################################

resource "azurerm_subnet_network_security_group_association" "lz" {
  subnet_id                 = azurerm_subnet.lz.id
  network_security_group_id = azurerm_network_security_group.lz.id
}
