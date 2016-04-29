resource "template_file" "consul_update" {
  template = "${module.shared.path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}

//
// CodeDeploy Instances
//
resource "aws_instance" "codedeploy" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.consul_client.id}",
    "${aws_security_group.instance_www.id}",
  ]
  subnet_id = "${element(split(",","${aws_subnet.subnet_a.id},${aws_subnet.subnet_b.id},${aws_subnet.subnet_c.id}"),count.index)}"

  iam_instance_profile = "${aws_iam_instance_profile.codedeploy.name}"

  # don't launch the instance before the profile's policy is attached
  depends_on = ["aws_iam_policy_attachment.codedeploy_instance"]

  count = 3

  tags {
    Name = "codedeploy_${count.index}"
    codedeploy = "true"
  }

  connection {
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/consul.d/consul_client.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/consul_template_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
      "${module.shared.path}/codedeploy-agent/installers/codedeploy-agent_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${template_file.consul_update.rendered}"]
  }

}

//
// Consul Servers
//
resource "aws_instance" "consul_0" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "consul_0"
  }

  connection {
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${template_file.consul_update.rendered}"]
  }

}

resource "aws_instance" "consul_1" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_b.id}"

  tags {
    Name = "consul_1"
  }

  connection {
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${template_file.consul_update.rendered}"]
  }

}

resource "aws_instance" "consul_2" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_c.id}"

  tags {
    Name = "consul_2"
  }

  connection {
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${template_file.consul_update.rendered}"]
  }

}
