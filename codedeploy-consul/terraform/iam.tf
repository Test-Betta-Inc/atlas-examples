//
// Service role for CodeDeploy service
//
resource "aws_iam_role" "codedeploy_service_role" {
  name = "${var.codedeploy_iam_role_name}"
  assume_role_policy = "${file("${module.shared.path}/codedeploy-agent/iam/CodeDeployDemo-Trust.json")}"
}

resource "aws_iam_policy_attachment" "codedeploy_service_role" {
  name       = "CodeDeployServiceRole"
  roles      = ["${aws_iam_role.codedeploy_service_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

//
// Instance profiles for instances running the CodeDeploy agent
//
resource "aws_iam_role" "codedeploy_instance" {
  name               = "CodeDeployDemo-EC2"
  assume_role_policy = "${file("${module.shared.path}/codedeploy-agent/iam/CodeDeployDemo-EC2-Trust.json")}"
}

resource "aws_iam_policy" "codedeploy_instance" {
  name   = "CodeDeployDemo-EC2-Permissions"
  policy = "${file("${module.shared.path}/codedeploy-agent/iam/CodeDeployDemo-EC2-Permissions.json")}"
}

resource "aws_iam_policy_attachment" "codedeploy_instance" {
  name       = "codedeploy"
  roles      = ["${aws_iam_role.codedeploy_instance.name}"]
  policy_arn = "${aws_iam_policy.codedeploy_instance.arn}"
}

resource "aws_iam_instance_profile" "codedeploy" {
  name  = "CodeDeployDemo-EC2-Instance-Profile"
  roles = ["${aws_iam_role.codedeploy_instance.name}"]
}
