variable "ami" {}
variable "security_group" {}
variable "key_name" {}
variable "instance_type" {}
variable "availability_zone" {}
variable "count" {}
variable "atlas_username" {}
variable "atlas_token" {}
variable "atlas_environment" {}
variable "user" {
    default = "ubuntu"
}
variable "key_file" {}
variable "agent" {
    default = false
}
