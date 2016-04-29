# codedeploy-consul

This example demonstrates using [Consul](https://www.consul.io/) for
service health checks and orchestrating deployments for an
[AWS CodeDeploy](https://aws.amazon.com/codedeploy/) application.

Specifically, Consul is used to:
- Register the CodeDeploy application in Consul's
[service catalog](https://www.consul.io/docs/agent/services.html) for service
discovery
- Mark the node as
["under maintenance"](https://www.consul.io/docs/commands/maint.html) during a
CodeDeploy deployment
- Prevent the CodeDeploy deployment from proceeding until the node and
application are healthy in Consul's service catalog
- Provide application data to the application from Consul's
[Key/Value Datastore](https://www.consul.io/intro/getting-started/kv.html)

## Getting Started

[Terraform](https://terraform.io/) is used to provision the example environment on Amazon Web Services including the VPC, load balancers, Consul cluster, and CodeDeploy instances. Additionally, a CodeDeploy Application named *SampleApp_Linux_Consul* and a CodeDeploy Deployment Group named *SampleApp_Linux_Consul* will be created.

[HashiCorp Atlas](https://hashicorp.com/atlas.html) is used to provide the initial bootstrap for the Consul cluster.

### Prerequisites

1. Install Terraform from the
[Downloads](https://www.terraform.io/downloads.html) page.

1. Set the following environment variables in your local shell:
  ```
  # For Atlas
  $ export ATLAS_TOKEN=YOUR_ATLAS_TOKEN
  $ export ATLAS_USERNAME=YOUR_ATLAS_USERNAME

  # For AWS
  $ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
  $ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  $ export AWS_DEFAULT_REGION=us-east-1
  ```
2. Create an S3 bucket for application files.  The bucket should be created in the same region you will create the CodeDeploy application.

  > The S3 bucket is not managed by Terraform because S3 buckets cannot be
  created, destroyed, and recreated quickly without
  [causing issues](http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html).

### Setup

1. Run the following command to generate an SSH key for use in this example.

  ```
  $ bash shared/ssh_keys/generate_key_pair.sh
  Generating RSA private key, 1024 bit long modulus
  .................................................................................++++++
  ........................++++++
  e is 65537 (0x10001)

  Public key: shared/ssh_keys/codedeploy-consul.pub
  Private key: shared/ssh_keys/codedeploy-consul.pem
  ```
1. Prepare the Terraform modules:

  ```
  $ terraform get -update terraform
  Get: file:///Users/clstokes/cc/hashicorp/atlas-examples/codedeploy-consul/shared (update)
  ```
1. Create the environment using Terraform:

  ```
  $ terraform apply terraform
  template_file.consul_update: Creating...
    rendered:                     "" => "<computed>"
  ...

  Apply complete! Resources: 51 added, 0 changed, 0 destroyed.
  ...

  Happy deploying!
  ```
1. Follow the instructions in the output from the previous `terraform apply` step to push and deploy the sample application with CodeDeploy.

> Note: AWS accounts can have different availability zones allocated to them -
e.g. your account might have zones _a_, _b_, and _c_ while someone else's
account might have zones _c_, _d_, and _e_. This project assumes _a_, _b_, and
_c_ are available. If you need to change these values, please see the section on
[Custom Variables](#custom-variables).

### Custom Variables

The defaults used for this project should work for most cases. If you would
like to customize the values, the easiest way is to create a `terraform.tfvars`
file in the top-level the `codedeploy-consul` directory. The
[Terraform documentation](https://www.terraform.io/intro/getting-started/variables.html)
can provide further explanation about variables.

To view the [Consul Web UI](https://www.consul.io/intro/getting-started/ui.html)
set the `consul_ui_access_cidr` variable shown below to your workstation's
public IP address.

Here is an example with customized values:

```
codedeploy_s3_bucket = "my-bucket-name"
codedeploy_s3_path   = "projects/codedeploy-consul"
zone_a               = "us-east-1b"
zone_b               = "us-east-1d"
zone_c               = "us-east-1e"

consul_ui_access_cidr = "172.31.0.0/16"
```

### Teardown

To teardown the example:

1. Use Terraform to destroy the environment:

  ```
  $ terraform destroy terraform
  Do you really want to destroy?
    Terraform will delete all your managed infrastructure.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes

  template_file.consul_update: Refreshing state... (ID: 17b15c60a9d113b81903c777fcb7bcdfed5c80d5166bbd530c7a85ad265c9f96)
  ...
  aws_vpc.main: Destroying...
  aws_vpc.main: Destruction complete

  Apply complete! Resources: 0 added, 0 changed, 51 destroyed.
  ```
1. Clean up any remaining application files in your S3 bucket.
