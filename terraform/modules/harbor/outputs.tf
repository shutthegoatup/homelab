output "url" {
  value = "https://${var.host}.${var.domain}"
}

output "username" {
  value = "admin"
}

output "password" {
  value = resource.random_password.robot_password.result
}
