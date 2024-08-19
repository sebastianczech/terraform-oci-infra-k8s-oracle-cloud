variable "compartment_id" {
  description = "Compartment ID"
  type        = string
}

variable "my_public_ip" {
  description = "My public IP address"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.my_public_ip))
    error_message = "Public IP address must be a valid IPv4 CIDR."
  }
}

variable "id_rsa_pub" {
  description = "SSH public key"
  type        = string
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  type        = string
  default     = "172.16.0.0/20"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  type        = string
  default     = "172.16.0.0/24"
}

# https://docs.oracle.com/en-us/iaas/images/ubuntu-2004/
# variable "instance_image" {
#   description = "OCID of image for instance"
#   type        = string
#   default     = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaafofmp3otdb5fh3ged2zhsepoh3e2dkaus636uee4vpt7jrgqssma"
# }

variable "instance_shape" {
  description = "Shape of instance"
  type        = string
  # default     = "VM.Standard.A1.Flex"
  default = "VM.Standard.E2.1.Micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 4
}

variable "availability_domains" {
  description = "Availability domains in which instances are going to be created"
  type        = list(number)
  default     = [0, 1, 2, 0]
}

variable "egress_security_rules" {
  description = "Egress security rules"
  type        = list(map(string))
  default     = []
}

variable "ingress_security_rules" {
  description = "Ingress security rules"
  type        = list(map(string))
  default     = []
}
