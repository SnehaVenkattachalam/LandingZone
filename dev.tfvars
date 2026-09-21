###############################################################################
# dev.tfvars — Development Landing Zone
#
# Usage:
#   terraform plan  -var-file="dev.tfvars"
#   terraform apply -var-file="dev.tfvars"
###############################################################################

# Naming & environment
prefix      = "corp"
environment = "dev"
location    = "australiaeast"

# Networking
vnet_address_space    = ["10.0.0.0/16"]
subnet_address_prefix = "10.0.1.0/24"

# NSG inbound rules — allow RDP from a specific management CIDR only
nsg_inbound_rules = [
  {
    name                       = "Allow-RDP-From-Management"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.10.0.0/24" # Replace with your management CIDR
    destination_address_prefix = "*"
  },
  {
    name                       = "Deny-RDP-From-Internet"
    priority                   = 200
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
]

# NSG outbound rules — allow all outbound (default Azure behaviour, made explicit)
nsg_outbound_rules = [
  {
    name                       = "Allow-All-Outbound"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
]

# Resource tags
tags = {
  cost_center   = "IT-LZ"
  owner         = "platform-team"
  criticality   = "low"
  auto_shutdown = "enabled"
}
