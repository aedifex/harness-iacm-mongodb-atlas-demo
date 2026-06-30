# Harness IaCM MongoDB Atlas Demo

This repository demonstrates how to provision a MongoDB Atlas database cluster using **Harness Infrastructure as Code Management (IaCM)** and Terraform.

The goal is simple: Harness runs the Terraform workflow, authenticates to MongoDB Atlas using managed secrets, and provisions the Atlas infrastructure from source-controlled Terraform code.

## What This Provisions

The Terraform configuration creates:

- A MongoDB Atlas Project
- A free-tier MongoDB Atlas `M0` cluster
- Atlas infrastructure managed through Terraform
- A repeatable IaCM workflow executed from Harness

## Architecture

```text
GitHub Repository
      |
      v
Harness IaCM Workspace
      |
      v
Terraform Init / Plan / Apply
      |
      v
MongoDB Atlas
      |
      v
Atlas Project + M0 Cluster
```

## Repository Structure

```text
.
├── main.tf
└── README.md
```

## Harness IaCM Setup

This demo is designed to run through a Harness IaCM workspace.

Recommended workspace configuration:

### Environment Variables

Use Harness secrets for MongoDB Atlas authentication:

```text
MONGODB_ATLAS_CLIENT_ID     = <+secrets.getValue("atlas_client_id")>
MONGODB_ATLAS_CLIENT_SECRET = <+secrets.getValue("atlas_client_secret")>
```

These values should come from a MongoDB Atlas service account.

### Terraform Variables

Use a workspace Terraform variable for the Atlas organization ID:

```text
org_id = <your-atlas-org-id>
```

The organization ID is not a secret, but it should still be managed consistently through the workspace.

## Terraform Workflow

Harness IaCM runs the standard Terraform workflow:

```text
terraform init
terraform plan
terraform apply
```

The pipeline should contain three IaCM Terraform steps:

1. Init
2. Plan
3. Apply

## MongoDB Atlas Requirements

Before running the pipeline, create a MongoDB Atlas service account with sufficient permissions.

Required permissions:

- Organization Project Creator, or
- Organization Owner

The service account must be able to create Atlas projects and clusters.

## Outputs

The Terraform configuration can expose the Atlas connection host using:

```hcl
output "mongodb_srv_host" {
  value = mongodbatlas_advanced_cluster.demo.connection_strings.standard_srv
}
```

This returns the Atlas SRV endpoint, for example:

```text
mongodb+srv://atlas-demo.xxxxx.mongodb.net
```

Application credentials should be managed separately through database users and secrets.

## Notes

This demo intentionally keeps the infrastructure minimal.

It is intended to prove the IaCM workflow:

```text
Harness IaCM → Terraform → MongoDB Atlas
```

For production use, add:

- Database users
- IP access lists
- Secret management for application connection strings
- Remote state strategy
- Policy checks
- Approval gates
- Cost controls
- Environment-specific workspaces

## Cleanup

To destroy the Atlas resources, run a destroy operation from the Harness IaCM workspace or locally with:

```bash
terraform destroy
```

Be careful when destroying shared Atlas projects or clusters.
