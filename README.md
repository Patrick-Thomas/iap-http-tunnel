<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.64, < 7 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.64, < 7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.64, < 7 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.64, < 7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_address.egress_ip](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_address) | resource |
| [google-beta_google_compute_address.ingress_ip](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_address) | resource |
| [google-beta_google_compute_backend_service.backend_service](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_backend_service) | resource |
| [google-beta_google_compute_forwarding_rule.forwarding_rule_http](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_forwarding_rule) | resource |
| [google-beta_google_compute_forwarding_rule.forwarding_rule_https](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_forwarding_rule) | resource |
| [google-beta_google_compute_region_network_endpoint_group.nginx_neg](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_region_network_endpoint_group) | resource |
| [google-beta_google_compute_router.egress_router](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_router) | resource |
| [google-beta_google_compute_router_nat.egress_nat](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_router_nat) | resource |
| [google-beta_google_compute_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_target_http_proxy) | resource |
| [google-beta_google_compute_target_https_proxy.https_proxy](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_target_https_proxy) | resource |
| [google-beta_google_compute_url_map.https_redirect](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_url_map) | resource |
| [google-beta_google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_url_map) | resource |
| [google_cloud_run_service_iam_binding.nginx_iap_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |
| [google_cloud_run_v2_service.nginx_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_compute_managed_ssl_certificate.ingress_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_iap_web_backend_service_iam_binding.lb_iap_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_backend_service_iam_binding) | resource |
| [google_secret_manager_secret.nginx_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_binding.nginx_config_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |
| [google_secret_manager_secret_version.version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.nginx_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domains"></a> [domains](#input\_domains) | Domains used for ingress traffic | `list(string)` | n/a | yes |
| <a name="input_iap_users"></a> [iap\_users](#input\_iap\_users) | Email addresses of users permitted to use this tunnel | `list(string)` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | OAuth client id. Keep this value private | `string` | n/a | yes |
| <a name="input_oauth_client_secret"></a> [oauth\_client\_secret](#input\_oauth\_client\_secret) | OAuth client secret. Keep this value private | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project where this tunnel will be created | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where resources will be created | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The subnet used for routing egress traffic | `string` | n/a | yes |
| <a name="input_target_url"></a> [target\_url](#input\_target\_url) | The destination URL for egress traffic. Must include protocol (http/https) and port | `string` | n/a | yes |
| <a name="input_tunnel_name"></a> [tunnel\_name](#input\_tunnel\_name) | Created resources will be appended with this name | `string` | `"tunnel"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->