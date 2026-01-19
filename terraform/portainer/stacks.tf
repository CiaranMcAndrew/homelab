locals {
    stacks = [
        {
            name      = "homepage"
            file_path = "applications/homepage/docker-compose.yml"
            env_vars = {
                PORTAINER_API_KEY = var.portainer_api_key
                PROXMOX_TOKEN_ID = var.proxmox_token_id
                PROXMOX_TOKEN_SECRET = var.proxmox_token_secret
            }
        },
        {
            name      = "pihole"
            file_path = "applications/pihole/docker-compose.yml"
            env_vars = {
                PIHOLE_WEBPASSWORD = var.pihole_webpassword
            }   
        },
        {
            name      = "traefik"
            file_path = "applications/traefik/docker-compose.yml"
        },
        {
            name      = "watchtower"
            file_path = "applications/watchtower/docker-compose.yml"
        },
        {
            name      = "media"
            file_path = "applications/media/docker-compose.yml"
            env_vars = {
                SONARR_API_KEY = var.sonarr_api_key
                RADARR_API_KEY = var.radarr_api_key
                PROWLARR_API_KEY = var.prowlarr_api_key
                JELLYFIN_API_KEY = var.jellyfin_api_key            }   
        },
        {
            name      = "torrent"
            file_path = "applications/torrent/docker-compose.yml"
            env_vars = {
                QBITTORRENT_PASSWORD = var.qbittorrent_password
                WIREGUARD_PASSWORD = var.wireguard_password
                WIREGUARD_PRIVATE_KEY = var.wireguard_private_key
                PROTON_USERNAME = var.proton_username
                PROTON_PASSWORD = var.proton_password
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
    file_path_in_repository   = each.value.file_path

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