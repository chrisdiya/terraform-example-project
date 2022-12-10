terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.25.0"
    }
  }
}

provider "google" {}

# Create a new project
resource "google_project" "example-new-proj" {
  name            = var.proj_name
  project_id      = var.proj_id
  org_id          = var.org_id
  billing_account = var.billing_account
}

# Enable 17 Google Cloud APIs
resource "google_project_service" "bigquery_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "bigquerymigration_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "bigquerymigration.googleapis.com"
}

resource "google_project_service" "cloudasset_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "cloudasset.googleapis.com"
}

resource "google_project_service" "logging_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "cloudapis_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "cloudapis.googleapis.com"
}

resource "google_project_service" "datastore_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "datastore.googleapis.com"
}

resource "google_project_service" "servicemanagement_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "servicemanagement.googleapis.com"
}

resource "google_project_service" "sql_component_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "sql-component.googleapis.com"
}

resource "google_project_service" "oslogin_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "oslogin.googleapis.com"
}

resource "google_project_service" "clouddebugger_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "clouddebugger.googleapis.com"
}

resource "google_project_service" "cloudtrace_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "cloudtrace.googleapis.com"
}

resource "google_project_service" "bigquerystorage_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "bigquerystorage.googleapis.com"
}

resource "google_project_service" "serviceusage_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "serviceusage.googleapis.com"
}

resource "google_project_service" "monitoring_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "compute_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "websecurityscanner_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "websecurityscanner.googleapis.com"
}

resource "google_project_service" "storage_api_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "storage-api.googleapis.com"
}

resource "google_project_service" "storage_component_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "storage-component.googleapis.com"
}

resource "google_project_service" "storage_googleapis_com" {
  project = google_project.example-new-proj.project_id
  service = "storage.googleapis.com"
}

# Sleep timer to allow API enablement to propagate before resource creation
resource "time_sleep" "wait_5_seconds" {
  depends_on = [google_project_service.compute_googleapis_com]
  create_duration = "5s"
}


# Create a new VPC
resource "google_compute_network" "vpc-1" {
  auto_create_subnetworks = false
  mtu                     = 1460
  name                    = "vpc-1"
  project                 = google_project.example-new-proj.project_id
  routing_mode            = "REGIONAL"

  depends_on = [time_sleep.wait_5_seconds]
}

# Create a new subnet in vpc-1
resource "google_compute_subnetwork" "sn-1" {
  name                       = "sn-1"
  network                    = google_compute_network.vpc-1.id
  ip_cidr_range              = "10.0.1.0/24"
  region                     = "us-central1"
  project                    = google_project.example-new-proj.project_id
  private_ip_google_access   = true
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  purpose                    = "PRIVATE"
  stack_type                 = "IPV4_ONLY"

  log_config {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }

  depends_on = [time_sleep.wait_5_seconds]
}

# Create 4 default firewall rules for vpc-1
resource "google_compute_firewall" "ingress_ping_private_allow" {
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  name          = "ingress-ping-private-allow"
  network       = google_compute_network.vpc-1.id
  priority      = 65531
  project       = google_project.example-new-proj.project_id
  source_ranges = ["10.0.1.0/24"]
  
  depends_on = [time_sleep.wait_5_seconds]
}

resource "google_compute_firewall" "ingress_ssh_iap_allow" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  name          = "ingress-ssh-iap-allow"
  network       = google_compute_network.vpc-1.id
  priority      = 65532
  project       = google_project.example-new-proj.project_id
  source_ranges = ["35.235.240.0/20"]
  
  depends_on = [time_sleep.wait_5_seconds]
}

resource "google_compute_firewall" "ingress_default_deny" {
  deny {
    protocol = "all"
  }
  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  name          = "ingress-default-deny"
  network       = google_compute_network.vpc-1.id
  priority      = 65534
  project       = google_project.example-new-proj.project_id
  source_ranges = ["0.0.0.0/0"]

  depends_on = [time_sleep.wait_5_seconds]
}

resource "google_compute_firewall" "egress_default_allow" {
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
  direction          = "EGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  name     = "egress-default-allow"
  network  = google_compute_network.vpc-1.id
  priority = 65533
  project  = google_project.example-new-proj.project_id

  depends_on = [time_sleep.wait_5_seconds]
}

# Create a service account
resource "google_service_account" "sa_proj_editor" {
  account_id   = "sa-proj-editor"
  description  = "service account with editor role on the project"
  display_name = "sa-proj-editor"
  project      = google_project.example-new-proj.project_id
}

# Assign project editor role to service account
resource "google_project_iam_policy" "project" {
  project     = google_project.example-new-proj.project_id
  policy_data = data.google_iam_policy.editor.policy_data
}

data "google_iam_policy" "editor" {
  binding {
    role = "roles/editor"

    members = ["serviceAccount:${google_service_account.sa_proj_editor.email}"]
  }
}
