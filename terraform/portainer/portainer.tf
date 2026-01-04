provider "portainer" {
  endpoint = var.portainer_endpoint

  # Option 2: Username/password authentication (generates JWT token internally)
  api_user     = var.portainer_admin_username
  api_password = var.portainer_admin_password

  skip_ssl_verify  = true # optional (default value is `false`)
}

resource "portainer_user_admin" "init_admin_user" {
  username = "admin"
  password = var.portainer_admin_password
}