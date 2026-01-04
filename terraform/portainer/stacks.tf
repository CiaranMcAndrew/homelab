locals {
    stacks = [
        {
            name      = "pihole"
            file_path = "applications/pihole/docker-compose.yml"
        },
        {
            name      = "media"
            file_path = "applications/media/docker-compose.yml"
            env_vars = {
                SONARR_API_KEY = var.sonarr_api_key
                JELLYFIN_API_KEY = var.jellyfin_api_key
            }   
        }
    ]
}

resource "portainer_stack" "stack" {
    for_each = { for stack in local.stacks : stack.name => stack }  
    name                      = each.value.name
    deployment_type           = "standalone"
    method                    = "repository"
    endpoint_id               = var.portainer_endpoint_id
    repository_url            = var.github_repo_url
    repository_reference_name = try(each.value.ref, "refs/heads/main")
    file_path_in_repository   = "docker-compose.yml"

    # Optional GitOps enhancements:
    stack_webhook             = true                      # Enables GitOps webhook
    update_interval           = "5m"                       # Auto-update interval
    pull_image                = true                       # Pull latest image on update
    force_update              = true                       # Prune services not in compose file

    # Dynamic block for optional env vars
    dynamic "env" {
    for_each = try(each.value.env_vars, {})
    content {
      name  = env.key
      value = env.value
    }
  }
}