#
# Project
#

data "google_project" "project" {
  project_id      = var.project
}

#
# Service accounts
#

resource "google_service_account" "nginx_agent" {
  account_id      = "${var.tunnel_name}-nginx-agent"
  display_name    = "${var.tunnel_name}-nginx-agent"
  project         = var.project
}

#
# Secrets
#

resource "google_secret_manager_secret" "nginx_config" {
  project         = var.project
  secret_id       = "${var.tunnel_name}-nginx-config"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "version" {
  deletion_policy = "DELETE"
  enabled         = true
  secret          = google_secret_manager_secret.nginx_config.id
  secret_data     = <<EOF
    server {
        # Listen at port 8080
        listen 8080; 
        # Server at localhost
        server_name _;
        # Enables gzip compression to make our app faster
        gzip on;

        location / {
            proxy_pass ${var.target_url};
            proxy_http_version 1.1;
        }
    }
  EOF
}

#
# IAM bindings
#

resource "google_secret_manager_secret_iam_binding" "nginx_config_binding" {
  project     = var.project
  secret_id   = google_secret_manager_secret.nginx_config.secret_id
  role        = "roles/secretmanager.secretAccessor"
  members     = [
    "serviceAccount:${google_service_account.nginx_agent.email}"
  ]
}

resource "google_cloud_run_service_iam_binding" "nginx_iap_binding" {
  project     = var.project
  location    = var.region
  service     = google_cloud_run_v2_service.nginx_service.name
  role        = "roles/run.invoker"
  members     = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-iap.iam.gserviceaccount.com"
  ]
}

resource "google_iap_web_backend_service_iam_binding" "lb_iap_binding" {
  project             = var.project
  web_backend_service = google_compute_backend_service.backend_service.name
  role                = "roles/iap.httpsResourceAccessor"
  members             = var.iap_users
}

#
# VPC
#

data "google_compute_subnetwork" "subnet" {
  project     = var.project
  region      = var.region
  name        = var.subnet
}

#
# IP addresses
#

resource "google_compute_global_address" "ingress_ip" {
  provider            = google-beta
  name                = "${var.tunnel_name}-ingress-ip"
  project             = var.project
  # region              = var.region
  # network_tier        = "PREMIUM"
}

resource "google_compute_address" "egress_ip" {
  provider            = google-beta
  name                = "${var.tunnel_name}-egress-ip"
  project             = var.project
  region              = var.region
  network_tier        = "STANDARD"
}

#
# Google managed SSL certificate
#

# resource "google_compute_managed_ssl_certificate" "ingress_certificate" {
#   name                      = "${var.tunnel_name}-ingress-certificate"
#   project                   = var.project
#   type                      = "MANAGED"

#   managed {
#       domains = var.domains
#   }
# }

#
# Cloud Run service
#

resource "google_cloud_run_v2_service" "nginx_service" {
  client       = "cloud-console"
  ingress      = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  launch_stage = "GA"
  location     = var.region
  name         = "${var.tunnel_name}-nginx-service"
  project      = var.project
  deletion_protection = false
  template {
    containers {
      image = "docker.io/nginx:1.27.1"
      name  = "nginx-1"
      ports {
        container_port = 8080
        name           = "http1"
      }
      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }
      startup_probe {
        failure_threshold     = 1
        initial_delay_seconds = 0
        period_seconds        = 240
        tcp_socket {
          port = 8080
        }
        timeout_seconds = 240
      }
      volume_mounts {
        mount_path = "/etc/nginx/conf.d"
        name       = "nginx-config"
      }
    }
    max_instance_request_concurrency = 80
    scaling {
      max_instance_count = 10
    }
    service_account = google_service_account.nginx_agent.email
    timeout         = "300s"
    volumes {
      name = "nginx-config"
      secret {
        items {
          path    = "default.conf"
          version = "latest"
        }
        secret = google_secret_manager_secret.nginx_config.name
      }
    }
    vpc_access {
      network_interfaces {
        network = regex("projects.*", data.google_compute_subnetwork.subnet.network)
        subnetwork = data.google_compute_subnetwork.subnet.name
      }
      egress = "ALL_TRAFFIC"
    }
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

#
# Serverless NEG
#

resource "google_compute_region_network_endpoint_group" "nginx_neg" {
  provider              = google-beta
  project               = var.project
  name                  = "${var.tunnel_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.nginx_service.name
  }
}

#
# Backend service
#

resource "google_compute_backend_service" "backend_service" {
  provider                        = google-beta
  name                            = "${var.tunnel_name}-backend-service"
  project                         = var.project
  affinity_cookie_ttl_sec         = 0
  connection_draining_timeout_sec = 300
  description                     = null
  enable_cdn                      = false
  load_balancing_scheme           = "EXTERNAL"
  locality_lb_policy              = null
  port_name                       = "http"
  protocol                        = "HTTP"
  session_affinity                = "NONE"
  timeout_sec                     = 30

  backend {
    balancing_mode                = "UTILIZATION"
    group                         = google_compute_region_network_endpoint_group.nginx_neg.id
    max_connections               = 0
    max_connections_per_endpoint  = 0
    max_connections_per_instance  = 0
    max_rate                      = 0
    max_rate_per_endpoint         = 0
    max_rate_per_instance         = 0
    max_utilization               = 0
  }

  iap {
    enabled = true
    oauth2_client_id              = var.oauth_client_id
    oauth2_client_secret          = var.oauth_client_secret
  }
}

#
# Url maps
#

resource "google_compute_url_map" "url_map" {
  provider                  = google-beta
  default_service           = google_compute_backend_service.backend_service.id
  name                      = "${var.tunnel_name}-url-map"
  project                   = var.project

  host_rule {
    hosts                   = [var.domain]
    path_matcher            = "main"
  }

  path_matcher {
    name = "main"
    default_service         = google_compute_backend_service.backend_service.id
  }
}

resource "google_compute_url_map" "https_redirect" {
  provider                  = google-beta
  default_service           = null
  name                      = "${var.tunnel_name}-https-redirect"
  project                   = var.project

  default_url_redirect {
    host_redirect           = null
    https_redirect          = true
    path_redirect           = null
    prefix_redirect         = null
    redirect_response_code  = "MOVED_PERMANENTLY_DEFAULT"
    strip_query             = false
  }
}

#
# Target proxies
#

resource "google_compute_target_http_proxy" "http_proxy" {
  provider                    = google-beta
  name                        = "${var.tunnel_name}-http-proxy"
  project                     = var.project
  url_map                     = google_compute_url_map.https_redirect.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  provider                          = google-beta
  name                              = "${var.tunnel_name}-https-proxy"
  project                           = var.project
  url_map                           = google_compute_url_map.url_map.id

  server_tls_policy                 = null
  # certificate_manager_certificates  = [var.certificate_id]
  certificate_map                   = "//certificatemanager.googleapis.com/${var.certificate_map_id}"
  ssl_policy                        = null
}

#
# Forwarding rules
#

resource "google_compute_global_forwarding_rule" "forwarding_rule_http" {
  provider                = google-beta
  name                    = "${var.tunnel_name}-forwarding-rule-http"
  project                 = var.project
  # region                  = var.region

  ip_protocol             = "TCP"
  load_balancing_scheme   = "EXTERNAL"
  port_range              = "80"
  target                  = google_compute_target_http_proxy.http_proxy.id
  ip_address              = google_compute_global_address.ingress_ip.address 
  # network_tier            = "PREMIUM"
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_https" {
  provider                = google-beta
  name                    = "${var.tunnel_name}-forwarding-rule-https"
  project                 = var.project
  # region                  = var.region

  ip_protocol             = "TCP"
  load_balancing_scheme   = "EXTERNAL"
  port_range              = "443"
  target                  = google_compute_target_https_proxy.https_proxy.id
  ip_address              = google_compute_global_address.ingress_ip.address
  # network_tier            = "PREMIUM" 
}

#
# NAT
#

resource "google_compute_router" "egress_router" {
  provider                            = google-beta
  project                             = var.project
  region                              = var.region
  name                                = "${var.tunnel_name}-router"
  network                             = data.google_compute_subnetwork.subnet.network
}

resource "google_compute_router_nat" "egress_nat" {
  provider                            = google-beta
  project                             = var.project
  region                              = var.region
  name                                = "${var.tunnel_name}-nat"
  router                              = google_compute_router.egress_router.name

  nat_ip_allocate_option              = "MANUAL_ONLY"
  nat_ips                             = [google_compute_address.egress_ip.self_link]

  source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
  subnetwork {
      name                            = data.google_compute_subnetwork.subnet.name
      source_ip_ranges_to_nat         = ["ALL_IP_RANGES"]
  }
}