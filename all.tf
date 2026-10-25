resource "aci_vmm_domain" "dvs-hacki" {
    provider_profile_dn = "uni/vmmp-VMware"
    name                = "dvs-hacki"
}

resource "aci_tenant" "hacki-tenant" {
    name        = "hacki-tenant-t"
    description = "This tenant was created by terraform"
}

resource "aci_vrf" "hacki-vrf" {
    tenant_dn              = aci_tenant.hacki-tenant.id
    name                   = "hacki-vrf"
    description            = "from terraform"
}

resource "aci_bridge_domain" "hacki-bd" {
    parent_dn                   = aci_tenant.hacki-tenant.id
    description                 = "from terraform"
    relation_fv_rs_ctx          = aci_vrf.hacki-vrf.id
    name                        = "hacki-bd"
}

resource "aci_subnet" "ten-o-three" {
    parent_dn        = aci_bridge_domain.hacki-bd.id
    description      = "subnet"
    ip               = "10.0.3.28/27"
}

resource "aci_filter" "http_flt" {
    tenant_dn  = aci_tenant.hacki-tenant.id
    name       = "http_flt"
}

resource "aci_filter_entry" "http" {
    filter_dn  = aci_filter.http_flt.id
    name       = "http"
    ether_t = "ip"
    prot = "tcp"
    stateful = "yes"
    d_from_port = 80
    d_to_port = 80
    s_from_port = 1024
    s_to_port = 65535
}

resource "aci_filter_entry" "https" {
    filter_dn  = aci_filter.http_flt.id
    name       = "https"
    ether_t = "ip"
    prot = "tcp"
    stateful = "yes"
    d_from_port = 443
    d_to_port = 443
    s_from_port = 1024
    s_to_port = 65535
}

resource "aci_contract" "http-ctr" {
    tenant_dn   =  aci_tenant.hacki-tenant.id
    description = "http contract"
    name        = "http-ctr"
}

resource "aci_contract_subject" "S1" {
    contract_dn   = aci_contract.http-ctr.id
    description   = "http and https"
    name          = "S1"
    relation_vz_rs_subj_filt_att = [aci_filter.http_flt.id]
}

resource "aci_application_profile" "test-app" {
  parent_dn   = aci_tenant.hacki-tenant.id
  name        = "test-app"
  description = "This app profile is created by terraform"
}

resource "aci_application_epg" "epg1" {
    application_profile_dn  = aci_application_profile.test-app.id
    name          = "epg1"
    description   = "from terraform"
    annotation    = "epg1"
    relation_fv_rs_bd = aci_bridge_domain.hacki-bd.id
    relation_fv_rs_cons = [aci_contract.http-ctr.id]
}

resource "aci_epg_to_domain" "dvs-hacki-for-epg1" {
    application_epg_dn    = aci_application_epg.epg1.id
    tdn                   = aci_vmm_domain.dvs-hacki.id
}

resource "aci_application_epg" "epg2" {
    application_profile_dn  = aci_application_profile.test-app.id
    name          = "epg2"
    description   = "from terraform"
    annotation    = "epg-2"
    relation_fv_rs_bd = aci_bridge_domain.hacki-bd.id
    relation_fv_rs_prov = [aci_contract.http-ctr.id]
}

resource "aci_epg_to_domain" "dvs-hacki-for-epg2" {
    application_epg_dn    = aci_application_epg.epg2.id
    tdn                   = aci_vmm_domain.dvs-hacki.id
}
