dns_zones = {
  "below.black" = {
    records = [
      {
        name  = ""
        type  = "A"
        value = "164.132.48.50"
      },
      {
        name  = ""
        type  = "CAA"
        value = "0 issue \"letsencrypt.org\""
      },
      {
        name  = "www"
        type  = "CNAME"
        value = "below.black."
      },
    ]
  }

  "below.industries" = {
    records = [
      {
        name  = ""
        type  = "A"
        value = "164.132.48.50"
      },
      {
        name  = ""
        type  = "CAA"
        value = "0 issue \"letsencrypt.org\""
      },
      {
        name  = "www"
        type  = "CNAME"
        value = "below.industries."
      },
    ]
  }

  "leo.surf" = {
    records = [
      {
        name  = ""
        type  = "A"
        value = "91.134.140.52"
      },
      {
        name  = "stats"
        type  = "A"
        value = "91.134.140.52"
      },
      {
        name  = ""
        type  = "CAA"
        value = "0 issue \"letsencrypt.org\""
      },
      {
        name  = "www"
        type  = "CNAME"
        value = "leo.surf."
      },
    ]
  }

  "yoko.cat" = {
    records = [
      {
        name  = ""
        type  = "A"
        value = "91.134.140.52"
      },
      {
        name  = ""
        type  = "CAA"
        value = "0 issue \"letsencrypt.org\""
      },
      {
        name  = "www"
        type  = "CNAME"
        value = "yoko.cat."
      },
    ]
  }
}
