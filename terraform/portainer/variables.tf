variable "gitlab_project_id" {
    type = string
    default = "77232437"
}

variable "gitlab_username" {
  type = string
  default = "ciaranmc1"
}

variable "gitlab_token" {
  type = string
}

variable "portainer_endpoint" {
  type = string
  default = "http://portainer.lab"
}

variable "portainer_admin_username" {
  type = string
  default = "admin"
}

variable "portainer_admin_password" {
  type = string
}

variable "github_repo_url" {
  type = string
  default = "https://github.com/CiaranMcAndrew/homelab.git"
}

variable "portainer_endpoint_id" {
  type = number
  default = "3"
}

variable "portainer_api_key" {
  type = string
  sensitive = true
}

variable "sonarr_api_key" {
  type = string
  sensitive = true
}

variable "radarr_api_key" {
  type = string
  sensitive = true  
}

variable "prowlarr_api_key" {
  type = string
  sensitive = true
}

variable "jellyfin_api_key" {
  type = string
  sensitive = true
}

variable "pihole_webpassword" {
  type = string
  sensitive = true
}

variable "wireguard_password" {
  type = string
  sensitive = true
}

variable "wireguard_private_key" {
  type = string
  sensitive = true  
}

variable "proton_username" {
  type = string
  sensitive = true
}

variable "proton_password" {
  type = string
  sensitive = true
}

variable "qbittorrent_password" {
  type = string
  sensitive = true
}