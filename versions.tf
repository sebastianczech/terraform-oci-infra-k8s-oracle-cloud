terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 6.30.0"
    }
  }
}
