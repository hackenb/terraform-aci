terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
}

provider "aci" {
  # cisco-aci user name
  username = "admin"
  # cisco-aci password
  password = "C1sco12345"
  # cisco-aci url
  url      = "https://apic1.corp.pseudoco.com"
  insecure = true
}
