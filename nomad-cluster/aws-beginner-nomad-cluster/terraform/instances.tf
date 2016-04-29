//
// Nomad Servers
//
resource "aws_instance" "nomad_0" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_0"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

}

resource "aws_instance" "nomad_1" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_1"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_0.private_ip}"
  }

}

resource "aws_instance" "nomad_2" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_2"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_0.private_ip}"
  }

}

//
// Nomad Clients
//
resource "aws_instance" "nomad_client" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_client"
  }

  count = 1

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/java_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

client {
  enabled = true
  servers = ["${aws_instance.nomad_0.private_ip}:4647","${aws_instance.nomad_1.private_ip}:4647","${aws_instance.nomad_2.private_ip}:4647"]
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

}
