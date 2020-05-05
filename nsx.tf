/*
#https://www.terraform.io/docs/providers/nsxt/index.html
provider nsxt {
  host                 = var.nsx_host
  username             = var.nsx_username
  password             = var.nsx_password
  allow_unverified_ssl = var.allow_unverified_ssl
}
/*
Note that you could also set environment variables for the provider in the following manner:
export NSXT_USERNAME="nsxuser"
export NSXT_PASSWORD="mysecurepassword"
export NSXT_MANAGER_HOST="nsx-manager@mydomain.local"
export NSXT_ALLOW_UNVERIFIED_SSL=true


#https://www.terraform.io/docs/providers/nsxt/r/policy_group.html
resource nsxt_policy_group "my" {
  display_name = "${var.prefix}-all"
  description  = var.description

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.prefix
    }
  }
}

resource nsxt_policy_group "all" {
  display_name = "${var.prefix}-all"
  description  = var.description

  criteria {
    ipaddress_expression {
      ip_addresses = var.subnet
    }
  }
}

#https://www.terraform.io/docs/providers/nsxt/d/policy_service.html
data nsxt_policy_service "ssh" {
  display_name = "SSH"
}

data nsxt_policy_service "icmp" {
  display_name = "ICMPv4-ALL"
}

data nsxt_policy_service "http" {
  display_name = "HTTP"
}

data nsxt_policy_service "https" {
  display_name = "HTTPS"
}

data nsxt_policy_service "dns" {
  display_name = "DNS"
}


#https://www.terraform.io/docs/providers/nsxt/r/policy_security_policy.html
resource nsxt_policy_security_policy "common" {
  display_name = "${var.prefix}-policy-common"
  description  = var.description
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  scope = [
    nsxt_policy_group.all.path
  ]

  rule {
    display_name = "allow_icmp_inbound"
    direction    = "IN"
    destination_groups = [
      nsxt_policy_group.my.path
    ]
    action = "ALLOW"
    services = [
      data.nsxt_policy_service.icmp.path
    ]
    logged = true
  }

  rule {
    display_name = "allow_icmp_outbound"
    direction    = "OUT"
    source_groups = [
      nsxt_policy_group.my.path
    ]
    action = "ALLOW"
    services = [
      data.nsxt_policy_service.icmp.path
    ]
    logged = true
  }

  rule {
    display_name       = "allow_ssh_inbound"
    direction          = "IN"
    destination_groups = [nsxt_policy_group.my.path]
    action             = "DROP"
    services = [
      data.nsxt_policy_service.ssh.path
    ]
    logged   = true
    disabled = true
    notes    = "Disabled by starfish for debugging"
  }

  rule {
    display_name = "allow_dns_outbound"
    direction    = "OUT"
    source_groups = [
      nsxt_policy_group.my.path
    ]
    action = "ALLOW"
    services = [
      data.nsxt_policy_service.dns.path
    ]
    logged = true
  }
}

resource nsxt_policy_security_policy "web" {
  display_name = "${var.prefix}-policy-web"
  description  = var.description
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  scope = [
    nsxt_policy_group.my.path
  ]

  rule {
    display_name = "allow_http_https"
    destination_groups = [
      nsxt_policy_group.my.path
    ]
    action = "ALLOW"
    services = [
      data.nsxt_policy_service.http.path,
      data.nsxt_policy_service.https.path
    ]
    logged = true
  }
}

