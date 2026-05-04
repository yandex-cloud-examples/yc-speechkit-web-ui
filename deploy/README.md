# Deployment Guide

This directory contains the Terraform configuration for deploying the SpeechKit Web UI application.

## Prerequisites

- Terraform installed
- Yandex Cloud account with appropriate permissions
- Service account authorized key file (`key.json`)

## Directory Structure

```
deploy/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── back.tf
│   ├── front.tf
│   ├── outputs.tf
│   └── key.json (you need to create this)
└── README.md (this file)
```

## Deployment Steps

1. Navigate to the terraform directory:
   ```bash
   cd deploy/terraform
   ```

2. Create the `private.auto.tfvars` file with your cloud and folder IDs:
   ```hcl
   cloud_id  = "b1g3xxxxxx"
   folder_id = "b1g7xxxxxx"
   ```

3. Create the authorized key file `key.json` in the `deploy/terraform` directory.

4. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform apply
   ```

5. After successful deployment, Terraform will output the URLs for:
   - The web application (bucket URL)
   - The API Gateway

## Cleanup

To remove all created resources:

1. Navigate to the terraform directory:
   ```bash
   cd deploy/terraform
   ```

2. Empty the created bucket manually (Terraform cannot destroy non-empty buckets)

3. Run:
   ```bash
   terraform destroy
   ```
