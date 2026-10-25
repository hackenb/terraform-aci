# Cisco ACI Terraform Example

This repository contains a minimal Terraform configuration for provisioning a Cisco ACI fabric using the `ciscodevnet/aci` provider. It creates a sample tenant, networking objects, and an application profile with endpoint groups to demonstrate contract-based communication in ACI.

Note that this repository is just a small example of how to use Terraform with ACI. The sample is based on the Cisco Dcloud demonstration 'Get Started with Cisco ACI 6.1'. Terraform is already installed on this demonstration so it should work right after cloning it (and after initializing the Fabric using NAC or UI).

## What this project creates

The configuration in `aci.tf` and `all.tf` provisions the following objects:

- ACI provider connection to an APIC endpoint
- Tenant: `hacki-tenant-t`
- VRF: `hacki-vrf`
- Bridge domain: `hacki-bd`
- Subnet: `10.0.3.28/27`
- Filter: `http_flt`
- Filter entries for TCP ports `80` and `443`
- Contract: `http-ctr`
- Application profile: `test-app`
- EPGs: `epg1` and `epg2`
- VMM domain attachment: `dvs-hacki`

The structure is intentionally simple and shows the common ACI building blocks used for a tenant-based application deployment:

- Tenant contains networking and policy components
- VRF provides the isolated L3 context
- Bridge domain provides Layer 2 forwarding and subnet configuration
- Filter and contract define allowed traffic
- Application profile groups EPGs for the application
- EPGs map to the bridge domain and attach to a VMM domain

## File layout

- `aci.tf` – Terraform and provider configuration
- `all.tf` – ACI resource definitions

## Provider configuration

The provider block connects to the APIC using a username, password, and URL. The example is configured as:

- Username: `admin`
- URL: `https://apic1.corp.pseudoco.com`
- Insecure mode enabled for example lab use

This is a convenience setup for a lab or test environment. In production, credentials and APIC endpoint details should be moved into environment variables or Terraform variables instead of being hard-coded in the configuration.

## Quick start

Initialize and apply the configuration:

```bash
terraform init
terraform plan
terraform apply
```

To remove the resources:

```bash
terraform destroy
```

## Notes on the ACI model

The terraform configuration demonstrates contract-based inter-EPG communication:

- `epg1` is configured as a consumer with `relation_fv_rs_cons = [aci_contract.http-ctr.id]`
- `epg2` is configured as a provider with `relation_fv_rs_prov = [aci_contract.http-ctr.id]`
- The HTTP/HTTPS filter allows common web traffic between the application tiers
- Both EPGs are bound to the same bridge domain and the same VMM domain

This is a good starting point for testing ACI policy, contracts, and endpoint group modeling before expanding to more complex multi-tier applications.

## Recommended hardening

Before using this in a real environment:

- Store APIC credentials in Terraform variables, environment variables, or a secret manager
- Replace hard-coded values with `var.apic_username`, `var.apic_password`, and `var.apic_url`
- Restrict `insecure = true` to non-production or lab-only scenarios
- Validate the APIC reachability and certificate trust model for your environment

## Additional references

- Terraform ACI provider docs: https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs
- Vim syntax highlighting for HCL: https://github.com/jvirtanen/vim-hcl.git
- ACI2TF import tooling: https://github.com/routingalchemy/ACI2TF_Import
