resource "aws_instance" "consul" {
    ami = "${var.ami}"
    security_groups = ["${var.security_group}"]
    key_name = "${var.key_name}"
    instance_type = "${var.instance_type}"
    availability_zone = "${var.availability_zone}"
    count = "${var.count}"

    tags {
      Name = "consul_${count.index+1}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo sed -i -- 's/{{ atlas_username }}/${var.atlas_username}/g' /etc/init/consul.conf",
            "sudo sed -i -- 's/{{ atlas_token }}/${var.atlas_token}/g' /etc/init/consul.conf",
            "sudo sed -i -- 's/{{ atlas_environment }}/${var.atlas_environment}/g' /etc/init/consul.conf",
            "sudo sed -i -- 's/{{ count }}/${var.count}/g' /etc/init/consul.conf",
            "sudo service consul restart"
        ]
        connection {
            user = "${var.user}"
            key_file = "${var.key_file}"
            agent = "${var.agent}"
        }
    }
}
