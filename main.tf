#https://registry.terraform.io/providers/hashicorp/vsphere/1.17.3/docs
provider vsphere {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}
/*
Note that you could also set environment variables for the provider in the following manner:
export VSPHERE_USER="username@mydomain.local"
export VSPHERE_PASSWORD="mysecurepassword"
export VSPHERE_SERVER="hostname.of.vcenter" (do not include https://)
export VSPHERE_ALLOW_UNVERIFIED_SSL=false
*/

#https://registry.terraform.io/providers/hashicorp/vsphere/1.17.3/docs/resources/tag_category
resource vsphere_tag_category "this" {
  name        = "${var.prefix}-vm-owner"
  description = var.description
  cardinality = "SINGLE"

  associable_types = [
    "VirtualMachine"
  ]
}

#https://registry.terraform.io/providers/hashicorp/vsphere/1.17.3/docs/resources/tag
resource vsphere_tag "this" {
  name        = "${var.prefix}-web"
  category_id = vsphere_tag_category.this.id
  description = var.description
}



#https://registry.terraform.io/providers/hashicorp/vsphere/1.17.3/docs/resources/virtual_machine
resource vsphere_virtual_machine "this" {
  name             = "${var.prefix}-vm"
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  datastore_id     = data.vsphere_datastore.this.id

  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = data.vsphere_virtual_machine.this.guest_id

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = data.vsphere_virtual_machine.this.network_interface_types[0]
  }
  wait_for_guest_net_timeout = 0

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.this.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.this.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.this.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.this.id

    customize {
      linux_options {
          host_name = "${var.prefix}-vm"
          domain    = var.domain
      }

      network_interface {
          ipv4_address = var.ipv4_address
          ipv4_netmask = var.ipv4_netmask
        }
      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_server_list
    }
  }
  /*
  extra_config = {
    "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
    "guestinfo.userdata.encoding" = "base64"
  }
  */
}

# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

# If you need ongoing management (Day N) of your virtual machines a tool such
# as Chef or Puppet is a better choice. These tools track the state of
# individual files and can keep them in the correct configuration.

# Here we do the following steps:
# Sync everything in files/ to the remote VM.
# Set up some environment variables for our script.
# Add execute permissions to our scripts.
# Run the deploy_app.sh script.
resource "null_resource" "configure-cat-app" {
  depends_on = [
    vsphere_virtual_machine.this
  ]
  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/hladmin/"

    connection {
      type        = "ssh"
      user        = var.os_user
      password    = var.os_password
      host        = var.ipv4_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo add-apt-repository universe",
      "sudo apt -y update",
      "sudo apt -y install apache2",
      "sudo systemctl start apache2",
      "sudo chown -R hladmin:hladmin /var/www/html",
      "chmod +x *.sh",
      "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
    ]

    connection {
      type        = "ssh"
      user        = var.os_user
      password    = var.os_password
      host        = var.ipv4_address
    }
  }
}

