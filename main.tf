terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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

resource "random_password" "db_password" {
  length  = 20
  special = false
}

resource "mongodbatlas_database_user" "demo" {
  project_id         = mongodbatlas_project.demo.id
  username           = "demo_user"
  password           = random_password.db_password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

output "mongodb_srv_host" {
  value = mongodbatlas_advanced_cluster.demo.connection_strings.standard_srv
}

output "mongodb_username" {
  value = mongodbatlas_database_user.demo.username
}

output "mongodb_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "mongodb_connection_string" {
  value = "mongodb+srv://${mongodbatlas_database_user.demo.username}:${random_password.db_password.result}@${trimprefix(mongodbatlas_advanced_cluster.demo.connection_strings.standard_srv, "mongodb+srv://")}/?appName=${mongodbatlas_advanced_cluster.demo.name}"

  sensitive = true
}