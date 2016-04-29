//
// Variables
//
variable "key_name" {}

//
// Outputs
//
output "path" {
  value = "${path.module}"
}

output "public_key_path" {
  value = "${path.module}/ssh_keys/${var.key_name}.pub"
}

output "private_key_path" {
  value = "${path.module}/ssh_keys/${var.key_name}.pem"
}
