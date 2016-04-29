Consul
===================
This repository and walkthrough guides you through deploying a Consul cluster on AWS.

General setup
-------------
1. [Download](https://www.terraform.io/downloads.html) and [install](https://www.terraform.io/intro/getting-started/install.html) Terraform.
2. Clone this repository.
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=consul-quick-start) and save your Atlas username as an environment variable in your `.bashrc` file.
  1. `export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable in your `.bashrc` file.
  1. `export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables in your `.bashrc` file.
  1. `export AWS_ACCESS_KEY=<your_aws_access_key>`
  2. `export AWS_SECRET_KEY=<your_aws_secret_key>`
6. When running `terraform` you can either pass environment variables into each call as noted in [ops/terraform/variables.tf#L7](ops/terraform/variables.tf#L7), or replace `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, `YOUR_ATLAS_USERNAME`, and `YOUR_ATLAS_TOKEN` with your Atlas username, Atlas token, [AWS Access Key Id, and AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars). If you use terraform.tfvars, you don't need to pass in environment variables for each `terraform` call, just be sure not to check this into a public repository.
7. Generate the keys in [ops/terraform/ssh_keys](ops/terraform/ssh_keys). You can simply run `sh scripts/generate_key_pair.sh` from the [ops/terraform](ops/terraform) directory and it will generate new keys for you. If you have an existing private key you would like to use, pass in the private key file path as the first argument of the shell script and it will use your key rather than generating a new one (e.g. `sh scripts/generate_key_pair.sh ~/.ssh/my-private-key.pem`). If you don't run the script, you will likely see the error `Error import KeyPair: The request must contain the parameter PublicKeyMaterial` on a `terraform apply` or `terraform push`.

_\** If you would like to build your own Consul cluster AMI with Packer to use instead of ours, see the below section [Build Your Own Consul Cluster AMI with Packer](README.md#build-your-own-consul-cluster-ami-with-packer). Note that this is not necessary for the following steps to work as we are already referencing a previously built public Consul AMI in the Terraform template._

Introduction and Configuring Consul
------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for configuring Consul and how the Atlas workflow fits in. [Consul](https://consul.io) is a tool for service discovery and configuration. A Consul agent lives on each of your nodes and reports both the service on the node (web server, database, worker, etc) and the health of the node. The end result is a real-time registry of services and their health, which can be used for service discovery and general architecture configuration. To learn more about Consul, its feature set, and interal workings, definitely check out its [dedicated website](https://consul.io).

Deploy a Three-node Consul Cluster
-----------------------------------
1. Navigate to the [ops/terraform](ops/terraform) directory on the command line.
2. Run `terraform remote config -backend-config name=<your_atlas_username>/consul` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas, keeping a versioned history of your infrastructure.
3. Get the latest consul module by running `terraform get` in the [ops/terraform](ops/terraform) directory.
4. To deploy your three-node Consul cluster, all you need to do is run `terraform push -name <your_atlas_username>/consul` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username.
5. Go to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the "consul" environment. Navigate to "Changes" on the left side panel of the environment, click on the latest "Run" and wait for the "plan" to finish, then click "Confirm & Apply" to deploy your Consul cluster.
   ![Confirm & Apply](screenshots/environments_changes_confirm.png?raw=true)
6. You should see 3 new boxes spinning up in EC2 named "consul_n", which are the 3 nodes in your Consul cluster.
   ![AWS - Success](screenshots/aws_success.png?raw=true)
7. That's it! You've just deployed a Consul cluster. In "Changes" you can view all of your configuration and state changes, as well as deployments. If you navigate back to "Status" on the left side panel, you will see the real-time health of all your nodes and services!
   ![Consul Infrastructure Status](screenshots/environments_status.png?raw=true)

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform push -name <your_atlas_username>/consul` and it will bring your infrastructure back to the state it was last at.

Build Your Own Consul Cluster AMI with Packer
------------------------
1. Make sure you have [Packer](https://packer.io/) [downloaded](https://www.packer.io/downloads.html) and [installed](https://www.packer.io/intro/getting-started/setup.html).
2. Replace `YOUR_ATLAS_USERNAME` in [ops/packer/consul.json](ops/packer/consul.json) with your Atlas username.
3. Navigate to the [ops/packer](ops/packer) directory on the command line.
4. Run `packer push -create consul.json` in the [ops/packer](ops/packer) directory.
5. Go to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and click on the "consul" build configuration. Navigate to "Variables" on the left side panel of the build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
6. Navigate back to "Builds" on the left side panel of your build configuration, then click "Rebuild" on the build configuration that errored. This one should succeed.
7. Update your [ops/terraform/main.tf](ops/terraform/main.tf) template to add your Atlas artifact as a resource and reference that artifact in the [consul module](ops/terraform/main.tf#L30) instead of the "ami" variable. See below code snippet.

   ```
   provider "atlas" {
       token = "${var.atlas_token}"
   }

   resource "atlas_artifact" "consul" {
       name = "${var.atlas_username}/consul"
       type = "aws.ami"
   }

   ...

   # Replace ami = "${var.ami}" (ops/terraform/main.tf#L30) with the below
   ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
   ```
8. Remove the "ami" variable from [ops/terraform/variables.tf#L34](ops/terraform/variables.tf#L34) and [ops/terraform/terraform.tfvars#L19](ops/terraform/terraform.tfvars#L19) as these are no longer required.
9. Refer to [Deploy a Three-node Consul Cluster](README.md#deploy-a-three-node-consul-cluster) to deploy using Terraform!
