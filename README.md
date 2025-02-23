# terraform-oci-infra-k8s-oracle-cloud

Terraform module to provision infrastructure used to create free Kubernetes cluster in Oracle Cloud

## Prerequisites

1. Install tools:
   - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - [OCI Command Line Interface (CLI)](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

## Usage

1. Authenticate to Oracle Cloud:

```bash
oci session authenticate --region eu-frankfurt-1 --profile-name k8s-oci
```

Token can be later refreshed by command:

```bash
oci session refresh --profile k8s-oci
```

2. Initialize Terraform:

```bash
cd examples/basic
terraform init
```

3. Prepare file with variables values:

```bash
cp example.tfvars terraform.tfvars
vi terraform.tfvars
```

4. Apply code for infrastructure:

```bash
terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 6.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.k8s_vcn_route_table](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_default_route_table) | resource |
| [oci_core_default_security_list.k8s_vcn_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_default_security_list) | resource |
| [oci_core_instance.k8s_node](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.k8s_internet_gateway](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_subnet.k8s_subnet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.k8s_vcn](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) | resource |
| [oci_network_load_balancer_backend.k8s_backend](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_backend) | resource |
| [oci_network_load_balancer_backend.nginx_http_backend](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_backend) | resource |
| [oci_network_load_balancer_backend_set.k8s_backend_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_backend_set.nginx_http_backend_set](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.k8s_listener](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_listener.nginx_http_listener](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.k8s_network_load_balancer](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/network_load_balancer_network_load_balancer) | resource |
| [oci_core_images.oci_ubuntu_images](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images) | data source |
| [oci_identity_availability_domains.ads](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_domains"></a> [availability\_domains](#input\_availability\_domains) | Availability domains in which instances are going to be created | `list(number)` | <pre>[<br/>  0,<br/>  1,<br/>  2,<br/>  0<br/>]</pre> | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment ID | `string` | n/a | yes |
| <a name="input_egress_security_rules"></a> [egress\_security\_rules](#input\_egress\_security\_rules) | Egress security rules | `list(map(string))` | `[]` | no |
| <a name="input_id_rsa_pub"></a> [id\_rsa\_pub](#input\_id\_rsa\_pub) | SSH public key | `string` | n/a | yes |
| <a name="input_ingress_security_rules"></a> [ingress\_security\_rules](#input\_ingress\_security\_rules) | Ingress security rules | `list(map(string))` | `[]` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to create | `number` | `4` | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | Shape of instance | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_my_public_ip"></a> [my\_public\_ip](#input\_my\_public\_ip) | My public IP address | `string` | n/a | yes |
| <a name="input_subnet_cidr_block"></a> [subnet\_cidr\_block](#input\_subnet\_cidr\_block) | Subnet CIDR | `string` | `"172.16.0.0/24"` | no |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | VCN CIDR | `string` | `"172.16.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_domain"></a> [availability\_domain](#output\_availability\_domain) | availability domain |
| <a name="output_compute_instances"></a> [compute\_instances](#output\_compute\_instances) | Names and IPs of created instances |
| <a name="output_compute_instances_public_ip"></a> [compute\_instances\_public\_ip](#output\_compute\_instances\_public\_ip) | Public IPs of created nodes |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | ID of LB |
| <a name="output_lb_public_ip"></a> [lb\_public\_ip](#output\_lb\_public\_ip) | Public IPs of LB |
| <a name="output_oci_ubuntu_images"></a> [oci\_ubuntu\_images](#output\_oci\_ubuntu\_images) | List of possible Ubuntu images |
| <a name="output_subnet_cidr"></a> [subnet\_cidr](#output\_subnet\_cidr) | CIDR block of the core subnet |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | ID of the core subnet |
| <a name="output_subnet_state"></a> [subnet\_state](#output\_subnet\_state) | The state of the subnet |
| <a name="output_vcn_cidr"></a> [vcn\_cidr](#output\_vcn\_cidr) | CIDR block of the core VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | ID of the core VCN |
| <a name="output_vcn_state"></a> [vcn\_state](#output\_vcn\_state) | the state of the VCN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

MIT Licensed. See [LICENSE](LICENSE).
