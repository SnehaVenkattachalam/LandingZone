# Landing Zone — Terraform Template

Minimal, enterprise-grade Terraform template that provisions the core Azure networking landing-zone resources for **Use Case 1**.

## Resources provisioned

| # | Resource | CAF name pattern |
|---|----------|-----------------|
| 1 | Resource Group | `rg-<prefix>-<environment>` |
| 2 | Virtual Network | `vnet-<prefix>-<environment>` |
| 3 | Subnet | `snet-<prefix>-<environment>` |
| 4 | Network Security Group | `nsg-<prefix>-<environment>` |
| 5 | NSG ↔ Subnet association | *(implicit resource)* |

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| Terraform | >= 1.0 |
| Azure CLI (`az`) | any recent version (used to create the Service Principal) |
| PowerShell | 5.1 or 7+ |

---

## Authentication setup

Authentication follows the same pattern as the sibling `avd_terraform-main` project — credentials are loaded from a `.env` file into shell environment variables. The AzureRM provider reads those variables automatically; nothing is hardcoded in Terraform.

### 1 — Create a Service Principal (once per environment)

```powershell
az ad sp create-for-rbac --name "sp-lz-terraform" `
  --role "Contributor" `
  --scopes "/subscriptions/<your-subscription-id>"
```

The command prints `appId`, `password`, and `tenant`. Use those values in the next step.

### 2 — Create the `.env` file

Copy `.env.example` to `.env` and fill in the real values:

```
ARM_CLIENT_ID=<appId>
ARM_CLIENT_SECRET=<password>
ARM_TENANT_ID=<tenant>
ARM_SUBSCRIPTION_ID=<your-subscription-id>
```

> `.env` is listed in `.gitignore` and will never be committed.

### 3 — Load credentials before every Terraform session

```powershell
.\set-auth.ps1
```

The script reads `.env`, sets the four `ARM_*` environment variables in your current PowerShell session, and validates that all four are present.

---

## Provisioning flow

```
.\set-auth.ps1                              # load credentials
terraform init                             # download azurerm provider
terraform validate                         # syntax / schema check
terraform plan  -var-file="dev.tfvars"     # preview changes
terraform apply -var-file="dev.tfvars"     # deploy
terraform destroy -var-file="dev.tfvars"   # tear down
```

Use `prod.tfvars` for the production environment.

---

## File reference

```
LandingZone/
├── .env.example          # credential template — copy to .env and fill in values
├── .gitignore            # excludes .env, state files, and .terraform/
├── set-auth.ps1          # loads .env → ARM_* environment variables
├── providers.tf          # Terraform / AzureRM provider version pinning
├── variables.tf          # all input variables with descriptions and validation
├── main.tf               # resource definitions (RG, VNet, Subnet, NSG, association)
├── outputs.tf            # key resource attributes exposed after apply
├── dev.tfvars            # development environment values
└── prod.tfvars           # production environment values
```

---

## Customising NSG rules

NSG rules are driven entirely by the `nsg_inbound_rules` and `nsg_outbound_rules` variables in your `.tfvars` file. Each rule follows this schema:

```hcl
{
  name                       = "Allow-RDP-From-Management"
  priority                   = 100          # 100–4096, lower = higher priority
  access                     = "Allow"      # "Allow" or "Deny"
  protocol                   = "Tcp"        # "Tcp", "Udp", "Icmp", or "*"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = "10.10.0.0/24"
  destination_address_prefix = "*"
}
```

Pass an empty list (`[]`) to rely solely on Azure's default NSG rules.
