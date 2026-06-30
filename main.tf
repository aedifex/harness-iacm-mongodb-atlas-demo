terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }
  }
}

provider "mongodbatlas" {}

locals {
  org_id = "6a42a6ab8f448e9c29edda26"
}

resource "mongodbatlas_project" "demo" {
  name   = "harness-atlas-demo"
  org_id = local.org_id
}

resource "mongodbatlas_advanced_cluster" "demo" {
  project_id   = mongodbatlas_project.demo.id
  name         = "atlas-demo"
  cluster_type = "REPLICASET"

  replication_specs = [{
    region_configs = [{
      provider_name         = "TENANT"
      backing_provider_name = "AWS"
      region_name           = "US_EAST_1"
      priority              = 7

      electable_specs = {
        instance_size = "M0"
      }
    }]
  }]
}

output "mongodb_srv_host" {
  value = mongodbatlas_advanced_cluster.demo.connection_strings.standard_srv
}