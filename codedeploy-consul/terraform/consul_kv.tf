resource "null_resource" "consul_kv" {

  connection {
    host     = "${aws_instance.codedeploy.0.public_ip}"
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -X PUT -d '${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}' http://${aws_instance.codedeploy.0.private_ip}:8500/v1/kv/${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}/environment",
      "curl -X PUT -d 'value1' http://${aws_instance.codedeploy.0.private_ip}:8500/v1/kv/${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}/key1",
      "curl -X PUT -d 'value2' http://${aws_instance.codedeploy.0.private_ip}:8500/v1/kv/${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}/key2",
      "curl -X PUT -d 'value3' http://${aws_instance.codedeploy.0.private_ip}:8500/v1/kv/${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}/key3",
    ]
  }

}
