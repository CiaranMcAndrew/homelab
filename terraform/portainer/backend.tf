locals {
    state_name = "portainer"
    gitlab_project_url = "https://gitlab.com/api/v4/projects/${var.gitlab_project_id}/terraform/state/${local.state_name}"
}

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "1.20.1"
    }
  }
  
  backend "http" {
    address        = local.gitlab_project_url
    lock_address   = "${local.gitlab_project_url}/lock"
    unlock_address = "${local.gitlab_project_url}/lock"
    username       = var.gitlab_username
    password       = var.gitlab_token  # or use TF_HTTP_PASSWORD env var
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}