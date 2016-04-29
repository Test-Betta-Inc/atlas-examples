Metamon
===================
This repository and walkthrough guides you through deploying [Metamon](https://github.com/tryolabs/metamon) on AWS using Atlas.

General setup
-------------
1. Download and install [Virtualbox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/downloads.html), [Packer](https://www.packer.io/downloads.html), and [Terraform](https://www.terraform.io/downloads.html).
2. Clone this repository.
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=metamon) and save your Atlas username as an environment variable in your `.bashrc` file.
   `export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable in your `.bashrc` file.
   `export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables in your `.bashrc` file.
   `export AWS_ACCESS_KEY=<your_aws_access_key>`
   `export AWS_SECRET_KEY=<your_aws_secret_key>`
6. In the [Vagrantfile](Vagrantfile) and Packer files [ops/site.json](ops/site.json) and [ops/consul.json](ops/consul.json) you must replace `YOUR_ATLAS_USERNAME` with your Atlas username.
7. When running `terraform` you can either pass environment variables into each call as noted in [ops/terraform/variables.tf#L7](ops/terraform/variables.tf#L7), or replace `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, `YOUR_ATLAS_USERNAME`, and `YOUR_ATLAS_TOKEN` with your Atlas username, Atlas token, [AWS Access Key Id, and AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars). If you use terraform.tfvars, you don't need to pass in environment variables for each `terraform` call, just be sure not to check this into a public repository.
8. Generate the keys in [ops/terraform/ssh_keys](ops/terraform/ssh_keys). You can simply run `sh scripts/generate_key_pair.sh` from the [ops/terraform](ops/terraform) directory and it will generate new keys for you. If you have an existing private key you would like to use, pass in the private key file path as the first argument of the shell script and it will use your key rather than generating a new one (e.g. `sh scripts/generate_key_pair.sh ~/.ssh/my-private-key.pem`). If you don't run the script, you will likely see the error `Error import KeyPair: The request must contain the parameter PublicKeyMaterial` on a `terraform apply` or `terraform push`.

Introduction and Configuring Metamon
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how the Atlas workflow fits in.

Metamon's [motivation](https://github.com/tryolabs/metamon#motivation) is to make it dead simple to setup a standardized, automated, and generic environment using Ansible playbooks. Metamon will [provision a Vagrant box](https://github.com/tryolabs/metamon#features) to be a development ready web app using Django, Gunicorn, Nginx, and PostgreSQL. Take a look at the [Metamon repository](https://github.com/tryolabs/metamon) for more context on how the provisioning works.

The files in this repository are designed to make it just as simple to move from development to production by safely deploying and managing your infrastructure on AWS using the Atlas workflow. If you haven't deployed an app with [Atlas](https://atlas.hashicorp.com) before, we recommend you start with the [introductory tutorial](https://atlas.hashicorp.com/help/getting-started/getting-started-overview). Atlas by [HashiCorp](https://hashicorp.com) is a platform to develop, deploy, and maintain applications on any infrastructure provider.

Step 1: Build a Consul Server AMI
-------------------------
1. Navigate to the [ops](ops) directory on the command line.
2. For Consul to work with this setup, we first need to create a Consul server AMI that will be used to build our Consul cluster. To do this, run `packer push -create consul.json` in the [ops](ops) directory. This will send the build configuration to Atlas so it can build your Consul server AMI remotely. You can follow [this walkthrough](https://github.com/hashicorp/atlas-examples/tree/master/consul) to get a better understanding of how we implemented this.
3. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "consul" build configuration. You will notice that the "consul" build errored immediately with the following error `Build 'amazon-ebs' errored: No valid AWS authentication found`. This is because we need to add our `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` environment variables to the build configuration.
   ![Consul Build Configuration - Variables Error](screenshots/builds_consul_error_variables.png?raw=true)
4. Navigate to "Variables" on the left side panel of the "consul" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
   ![Consul Build Configuration - Variables](screenshots/builds_variables.png?raw=true)
5. Navigate back to "Versions" on the left side panel of the "consul" build configuration, then click "Rebuild" on the "consul" build configuration that errored. This one should succeed.
   ![Consul Build Configuration - Success](screenshots/builds_consul_success.png?raw=true)
6. This creates a fully-baked Consul server AMI that will be used for your Consul cluster.

Step 2: Build a Metamon AMI
-------------------------
1. Navigate to the [ops](ops) directory on the command line.
2. Build an AMI using Metamon's Ansible provisioning that will create a functioning web app that uses Django, Gunicorn, Nginx, PostgreSQL and a few other [Metamon features](https://github.com/tryolabs/metamon#features). To do this, run `packer push -create site.json` in the [ops](ops) directory. This will send the build configuration to Atlas so it can build your Metamon AMI remotely.
3. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "metamon" build configuration. You will notice that the "metamon" build configuration errored immediately with the following error `* Bad source '/packer/app': stat /packer/app: no such file or directory`. This is because there is a [provisioner in the ops/site.json](ops/site.json#L65) Packer template that is expecting the application to already be linked. If you take that provisioner out, it would work, but you're just going to need it back in there after you link your application in the next step. This error is fine for now, we will be fixing this shortly.
   ![Metamon Build Configuration - Application Error](screenshots/builds_metamon_error_application.png?raw=true)
4. We also need to add our environment variables for the "metamon" build configuration so we don't get the same error we got with the "consul" build configuration. Navigate to "Variables" on the left side panel of the "metamon" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
   ![Metamon Build Configuration - Variables](screenshots/builds_variables.png?raw=true)

Step 3: Link your Application Code
-------------------------
1. Navigate to the [root]() directory of your project where the Vagrant file is directory on the command line.
2. You'll now want to link up your actual Metamon application code to Atlas so that when you make any code changes, you can `vagrant push` them to Atlas and it will rebuild your AMI automatically. To do this, simply run `vagrant push` in the [root]() directory of your project.
3. This will send your application code to Atlas, which is everything in the [app](app) directory. Link the "metamon" application and build configuration by clicking "Links" on the left side panel of the "metamon" build configuration in the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account. Complete the form with your Atlas username, `metamon` as the application name, and `/app` as the destination path.
   ![Metamon Build Configuration - Links](screenshots/builds_metamon_links.png?raw=true)
4. Now that your "metamon" application and build configuration are linked, navigate back to "Versions" on the left side panel of the "metamon" build configuration, then click "Rebuild" on the "metamon" build configuration that errored. This one should succeed.
   ![Metamon Build Configuration - Success](screenshots/builds_metamon_success.png?raw=true)
5. This creates a fully-baked Django web app AMI that uses Consul for service discovery/configuration and health checking.

_\** `packer push site.json` will rebuild the AMI with the application code that was last pushed to Atlas whereas `vagrant push` will push your latest application code to Atlas and THEN rebuild the AMI. When you want any new modifications of your application code to be included in the AMI, do a `vagrant push`, otherwise if you're just updating the packer template and no application code has changed, do a `packer push site.json`._

Step 4: Deploy Metamon Web App and Consul Cluster
--------------------------
1. Wait for both the “consul” and “metamon” builds to complete without errors
2. Navigate to the [ops/terraform](ops/terraform) directory on the command line.
3. Run `terraform remote config -backend-config name=<your_atlas_username>/metamon` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas, keeping a versioned history of your infrastructure.
4. Get the latest modules by running `terraform get` in the [ops/terraform](ops/terraform) directory.
5. Run `terraform push -name <your_atlas_username>/metamon` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username.
6. Go to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the "metamon" environment. Navigate to "Changes" on the left side panel of the environment, click on the latest "Run" and wait for the "plan" to finish, then click "Confirm & Apply" to deploy your Metamon web app and Consul cluster.
   ![Confirm & Apply](screenshots/environments_changes_confirm.png?raw=true)
7. You should see 4 new boxes spinning up in EC2, one named "metamon_1", which is your web app, and three named "consul_n", which are the nodes in your Consul cluster.
   ![AWS - Success](screenshots/aws_success.png?raw=true)
8. That's it! You just deployed a a Metamon web app and Consul cluster. In "Changes" you can view all of your configuration and state changes, as well as deployments. If you navigate back to "Status" on the left side panel, you will see the real-time health of all your nodes and services.
   ![Infrastructure Status](screenshots/environments_status.png?raw=true)

Final Step: Verify it Worked!
------------------------
1. Once the "metamon_1" box is running, go to its public ip and you should see a website that reads "Hello, Atlas!"
   ![Hello, Atlas!](screenshots/hello_atlas.png?raw=true)
2. Change your app code by modifying [app/app/views.py](app/app/views.py#L6) to say "Hello, World!" instead of "Hello, Atlas!".
3. Run `vagrant push` in your projects [root]() directory (where the Vagrantfile is). Once the packer build finishes creating the new AMI (view this in [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account), run `terraform push -name <your_atlas_username>/metamon` in the [ops/terraform](ops/terraform) directory.
4. Go to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the "metamon" environment. Navigate to "Changes" on the left side panel of the environment, click on the latest "Run" and wait for the "plan" to finish, then click "Confirm & Apply" to deploy your updated Metamon web app! Go to the new "metamon_1" box's public ip and it should now say "Hello, World!".

_\** One thing to note... Because your Django web app and PostgreSQL are running on the same box, anytime you rebuild that AMI and deploy, it's going to destroy the instance and create a new one - effectively destroying all of your data._

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform push -name <your_atlas_username>/metamon` and it will bring your infrastructure back to the state it was last at.

