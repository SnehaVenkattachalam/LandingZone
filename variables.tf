###############################################################################
# variables.tf — Landing Zone
#
# All configurable values are declared here as Terraform variables.
# No defaults contain subscription IDs, tenant IDs, CIDRs, or credentials.
# Supply values via a .tfvars file (e.g. dev.tfvars) or environment-specific
# auto.tfvars files.
###############################################################################

# ---------------------------------------------------------------------------
# Naming & environment
# ---------------------------------------------------------------------------

variable "prefix" {
  description = "Short prefix applied to every resource name. Use lowercase letters and numbers only (e.g. 'corp', 'lz', 'myorg')."
  type        = string
}

variable "environment" {
  description = "Deployment environment label appended to resource names (e.g. 'dev', 'test', 'prod')."
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region in which all resources will be deployed (e.g. 'australiaeast', 'eastus', 'westeurope')."
  type        = string
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "RFC 1918 address space(s) for the Virtual Network (e.g. [\"10.0.0.0/16\"])."
  type        = list(string)
}

variable "subnet_address_prefix" {
  description = "CIDR prefix for the subnet. Must fall within vnet_address_space (e.g. \"10.0.1.0/24\")."
  type        = string
}

# ---------------------------------------------------------------------------
# NSG rules
# ---------------------------------------------------------------------------

variable "nsg_inbound_rules" {
  description = <<EOT
List of custom inbound NSG rules. Each rule must include:
  name                       — unique rule name
  priority                   — integer 100–4096 (lower = higher priority)
  access                     — "Allow" or "Deny"
  protocol                   — "Tcp", "Udp", "Icmp", or "*"
  source_port_range          — port, range, or "*"
  destination_port_range     — port, range, or "*"
  source_address_prefix      — CIDR, service tag, or "*"
  destination_address_prefix — CIDR, service tag, or "*"
EOT
  type = list(object({
    name                       = string
    priority                   = number
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.nsg_inbound_rules :
      contains(["Allow", "Deny"], r.access) &&
      r.priority >= 100 && r.priority <= 4096
    ])
    error_message = "Each inbound rule must have access = 'Allow' or 'Deny' and priority between 100 and 4096."
  }
}

variable "nsg_outbound_rules" {
  description = "List of custom outbound NSG rules. Same schema as nsg_inbound_rules."
  type = list(object({
    name                       = string
    priority                   = number
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.nsg_outbound_rules :
      contains(["Allow", "Deny"], r.access) &&
      r.priority >= 100 && r.priority <= 4096
    ])
    error_message = "Each outbound rule must have access = 'Allow' or 'Deny' and priority between 100 and 4096."
  }
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Map of tags applied to every resource. Merged with standard tags defined in locals."
  type        = map(string)
  default     = {}
}
