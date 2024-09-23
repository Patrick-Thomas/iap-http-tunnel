variable "tunnel_name" {
	description 	= "Created resources will be appended with this name"
	type 			= string
	default 		= "tunnel"
}

variable "project" {
	description 	= "The ID of the project where this tunnel will be created"
	type 			= string
}

variable "region" {
	description 	= "The region where resources will be created"
	type 			= string
}

variable "subnet" {
	description		= "The subnet used for routing egress traffic"
	type 			= string
}

variable "target_url" {
	description 	= "The destination URL for egress traffic. Must include protocol (http/https) and port"
	type 			= string
}

variable "iap_users" {
	description 	= "Email addresses of users permitted to use this tunnel"
	type			= list(string)
}

variable "domain" {
	description 	= "Domain used for ingress traffic"
	type 			= string
}

variable "oauth_client_id" {
	description 	= "OAuth client id. Keep this value private"
	type 			= string
}

variable "oauth_client_secret" {
	description 	= "OAuth client secret. Keep this value private"
	type 			= string
}

variable "certificate_map_id" {
	description 	= "Google managed certificate map id"
	type 			= string
}