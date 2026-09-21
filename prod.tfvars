###############################################################################
# prod.tfvars — Production Landing Zone
#
# Usage:
#   terraform plan  -var-file="prod.tfvars"
#   terraform apply -var-file="prod.tfvars"
###############################################################################

# Naming & environment
prefix      = "corp"
environment = "prod"
location    = "australiaeast"

# Networking — larger address space for production workloads
vnet_address_space    = ["10.1.0.0/16"]
subnet_address_prefix = "10.1.1.0/24"

# NSG inbound rules — tighter controls for production
nsg_inbound_rules = [
  {
    name                       = "Allow-HTTPS-From-Internet"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-RDP-From-Management"
    priority                   = 200
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.10.0.0/24" # Replace with your management CIDR
    destination_address_prefix = "*"
  },
  {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

# NSG outbound rules
nsg_outbound_rules = [
  {
    name                       = "Allow-HTTPS-Outbound"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  },
  {
    name                       = "Deny-All-Outbound"
    priority                   = 4000
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

# Resource tags
tags = {
  cost_center = "IT-LZ"
  owner       = "platform-team"
  criticality = "high"
}
