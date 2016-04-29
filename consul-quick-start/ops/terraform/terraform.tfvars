/* You can either use this terraform.tfvars file to pass variables
to terraform and ignore it from version control, or just
pass them in through the command line as noted in variables.tf
See https://www.terraform.io/intro/getting-started/variables.html */

# Required Variables
aws_access_key = "YOUR_AWS_ACCESS_KEY"
aws_secret_key = "YOUR_AWS_SECRET_KEY"
atlas_username = "YOUR_ATLAS_USERNAME"
atlas_token = "YOUR_ATLAS_TOKEN"

# Optional Configuration Variables - Uncomment and populate
# the variables below with your desired configuration to
# override the defaults in ops/terraform/variables.tf
# atlas_environment = "consul"
# region = "us-east-1"
# private_key = "ssh_keys/consul-key.pem"
# public_key = "ssh_keys/consul-key.pub"
# ami = "ami-dc1529b4"
# instance_type = "t2.micro"
# availability_zone = "us-east-1a"
# count = 3
