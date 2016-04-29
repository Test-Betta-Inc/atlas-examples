provider "atlas" {
    token = "${var.atlas_token}"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "atlas_artifact" "metamon" {
    name = "${var.atlas_username}/metamon"
    type = "aws.ami"
}

resource "atlas_artifact" "consul" {
    name = "${var.atlas_username}/consul"
    type = "aws.ami"
}

resource "aws_security_group" "allow_all" {
    name = "allow_all"
    description = "Allow all inbound traffic"

    tags {
      Name = "allow_all"
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "metamon" {
    key_name = "metamon-key-pair"
    public_key = "${file(var.metamon_public_key)}"
}

resource "aws_key_pair" "consul" {
    key_name = "consul-key-pair"
    public_key = "${file(var.consul_public_key)}"
}

module "metamon" {
    source = "./metamon"
    ami = "${atlas_artifact.metamon.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.metamon.key_name}"
    instance_type = "${var.metamon_instance_type}"
    availability_zone = "${var.metamon_availability_zone}"
    count = "${var.metamon_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.metamon_private_key}"
}

module "consul" {
    source = "./consul"
    ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.consul.key_name}"
    instance_type = "${var.consul_instance_type}"
    availability_zone = "${var.consul_availability_zone}"
    count = "${var.consul_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.consul_private_key}"
}
