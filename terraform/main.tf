locals {
  dns_record_types_with_fqdn_targets = ["CNAME", "MX", "SRV"]

  dns_records = flatten([
    for zone_name, zone in var.dns_zones : [
      for record in zone.records : {
        zone  = zone_name
        name  = record.name
        type  = upper(record.type)
        value = record.value
        ttl   = record.ttl
      }
    ]
  ])
}

resource "ovh_domain_zone_record" "records" {
  for_each = {
    for record in local.dns_records :
    "${record.zone}/${record.name}/${record.type}/${record.value}" => record
  }

  zone      = each.value.zone
  subdomain = each.value.name
  fieldtype = each.value.type
  target = (
    contains(local.dns_record_types_with_fqdn_targets, each.value.type) && !endswith(each.value.value, ".")
    ? "${each.value.value}."
    : each.value.value
  )
  ttl = each.value.ttl
}
