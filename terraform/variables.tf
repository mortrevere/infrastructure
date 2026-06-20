variable "ovh_endpoint" {
  description = "OVH API endpoint. Override with TF_VAR_ovh_endpoint when needed."
  type        = string
  default     = "ovh-eu"
}

variable "dns_zones" {
  description = "OVH DNS zones and their managed A, AAAA, and CNAME records."
  type = map(object({
    records = list(object({
      name  = string
      type  = string
      value = string
      ttl   = optional(number, 3600)
    }))
  }))

  default = {
    "below.black" = {
      records = []
    }
    "below.industries" = {
      records = []
    }
    "leo.surf" = {
      records = []
    }
    "yoko.cat" = {
      records = []
    }
  }

  validation {
    condition = alltrue(flatten([
      for zone in values(var.dns_zones) : [
        for record in zone.records : contains(["A", "AAAA", "CNAME"], upper(record.type))
      ]
    ]))
    error_message = "DNS records may only use A, AAAA, or CNAME."
  }

  validation {
    condition = alltrue(flatten([
      for zone in values(var.dns_zones) : [
        for record in zone.records : upper(record.type) != "CNAME" || record.name != ""
      ]
    ]))
    error_message = "CNAME records cannot be created at the zone apex."
  }
}
