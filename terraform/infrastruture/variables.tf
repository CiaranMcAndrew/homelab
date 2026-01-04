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

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_user" {
  type = string
}

variable "proxmox_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_token_secret" {
  type = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
  default = "lab"
}

variable "vm_storage" {
  default = "local-lvm"
}

variable "ssh_public_key" {
  type = string
}

variable "template_name" {
  type    = string
  default = "ubuntu-2204-template"
}