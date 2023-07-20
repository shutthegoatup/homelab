output "url" {
  value = "https://${var.host}.${var.domain}"
}

output "username" {
  value = "admin"
}

output "password" {
  value = random_password.helm_password.result
}
