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
      {
        name  = ""
        type  = "MX"
        value = "1 mail.mxwell.fr."
      },
      {
        name  = "autodiscover"
        type  = "CNAME"
        value = "mail.mxwell.fr."
      },
      {
        name  = "_autodiscover._tcp"
        type  = "SRV"
        value = "0 0 8888 mail.mxwell.fr."
      },
      {
        name  = "autoconfig"
        type  = "CNAME"
        value = "mail.mxwell.fr."
      },
      {
        name  = ""
        type  = "TXT"
        value = "v=spf1 mx a -all"
      },
      {
        name  = "_dmarc"
        type  = "TXT"
        value = "v=DMARC1; p=reject; adkim=s; aspf=s; sp=none"
        ttl   = 3600
      },
      {
        name  = "dkim._domainkey"
        type  = "TXT"
        value = "v=DKIM1;k=rsa;t=s;s=email;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwVETZ+50osu0PFmFa0g60bKP9+SDNN/qO6WT96PIsv6Xdu74Xj76E9Mpkq6Q/oluEt7m3ehWUtZxvg0iqO7fy3kSJ6HzDWC1+Rbq5sg3X+WxYBWGZ10+KbjSL7F7s1tNXmxwa7w+oPSqaoai0VVixmL71dfAcprXB/Ypxyq21EM5ZR0UD8MfIROmLcCFJcil2sSb03QmeBPrS8cgatDPyfxqutPTc8rG85oO5eTAllpdxkT974lRiuCdSAclWQfWENVPFY0z3SbGun829lSseknkik6INNmi4f/wQ/F5ndeKNM6u1fE9yFKcsEjtdEeJdotQc7crFOinCK4mU6EKHwIDAQAB"
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

  "estcequilfaitchaud.fr" = {
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
        value = "estcequilfaitchaud.fr."
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
