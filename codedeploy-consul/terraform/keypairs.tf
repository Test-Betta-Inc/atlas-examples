resource "aws_key_pair" "main" {
  key_name   = "${var.key_name}"
  public_key = "${file(module.shared.public_key_path)}"
}
