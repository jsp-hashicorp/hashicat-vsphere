# vSphere Variables

variable vsphere_user {
  type = string
  description = "The user account that you will authenticate to vSphere with."
}

variable vsphere_password {
  type = string
  description = "The password for your vSphere user."
}

variable vsphere_server {
  type = string
  description = "The hostname of the vCenter Server to authenticate against."
}

variable allow_unverified_ssl {
  type    = bool
  default = true
  description = "Whether you permit a certificate from an untrusted source. Used for self-signed certificates."
}

variable datacenter_name {
  type = string
  description = "The vSphere datacenter object in which you want to create and manage resources."
}

variable cluster_name {
  type = string
  description = "The vSphere compute cluster that you will deploy workloads to."
}

variable datastore_name {
  type = string
  description = "The vSphere datastore that you want to use for virtual machine storage."
}

variable vm_network_name {
  type = string
}

variable template_name {
  type = string
}

variable vm_count {
  type    = number
  default = 1
}

variable num_cpus {
  type    = number
  default = 1
}

variable memory {
  type    = number
  default = 2048
}

# OS Variables

variable os_user {
  type = string
}

variable os_password {
  type = string
}

# Webiste variables

variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "placeholder" {
  default     = "placekitten.com"
  description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
}


# NSX Variables

variable nsx_host {
  type = string
}

variable nsx_username {
  type = string
}

variable nsx_password {
  type = string
}

variable prefix {
  type = string
}

variable description {
  type    = string
  default = ""
}

variable subnet {
  type    = list(string)
  default = []
}