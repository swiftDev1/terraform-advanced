# terraform-demos
Learn Terraform core concepts with hands-on demos

Terraform Workflow:
1. Terraform init
2. terraform validate
3. terraform plan
4. terraform apply
5. terraform destroy

terraform fmt

**Terraform init** is used to initialize a working directory containing terraform config files. It initializes the backend and downloads your plugins/providers.  
**Terraform validate** ensures that the configurations are syntactically valid and internally consistent.
**Terraform plan** creates an execution plan; shows you what it plans to create, delete, or update. It performs a refresh and determines what actions are necessary to achieve the desired state as stated in the configuration files.  
**Terraform apply** is used to apply the changes needed to reach the desired configuration.  
**Terraform destroy** is used to destroy any terraform-managed infrastructure. Usually asks for confirmation before destroying.  
*If you have a default VPC in that region, you don't need to specify any VPC-related configuration in your files.*  
*Whenever you are executing terraform commands, ensure you are inside the working directory.*  
/*  
This is  
a multi-line  
comment in terraform.  
*/  

**Terraform block** is used to specify the required terraform version, specify the provider requirements, and configure the backend. Within a terraform block, only constant values can be used. Arguments cannot refer to named objects such as resources, input variables, etc, and may not use any of Teraform's built-in functions. This block was introduced in version 0.13 and later. Whenever you run terraform commands, it checks to see if your current terraform version matches your CLI version. This can potentially cause breaking changes in production. This is why it is important to lock your terraform version in the terraform block.  
**Provider block**: Terraform relies on the providers to interact with remote systems such as AWS, Azure, GCP, etc through their cloud-related APIs. Provider configurations belong to the **Root Module**. Other modules are called child modules.  
**required_version**  
Required version focuses on the underlying Terraform CLI installed on your system. If the running version of Terraform on your desktop doesn't match the constraints specified on your Terraform block [or the latest Terraform version if no constraint is provided], terraform will produce an error and exit without taking any further actions.  
~> allows only the rightmost value to increase. _required_version = "~>1.0.4"_ will accept 1.0.5 and 1.0.10 but will not accept 1.1.0. _required_version = "~>1.0"_ will work for all patch releases of the minor release 0 and also all minor releases of the major version 1 such as v1.24 [remember it is the rightmost version that is being considered. Sometimes people prefer to be strict in the production environment and lock down to a particular version of terraform as so _required_version = "1.0.4". Choosing between these two depends on the sensitivity of the environment.  {using ~ simply means u want to restrict what can increase unlike using > like that which permits everything to be increased. But then again, while using the ~, ensure you include the 3 versions. Adding just the major and minor versions can cause breaking changes as there are usually many changes associated with minor version upgrades. Just to be safe in production}  
**Required provider**  
This is used to specify all the plugins needed to run that module. It maps each provider to a source address and a version constraint. Say u changed the provider version in your configuration file, you need to run _terraform init -upgrade_ cos terraform has already downloaded the previous version to your .terraform folder.  
Providers are the heart of Terraform. When you run terraform init, it downloads the provider version specified from the terraform registry into your .terraform folder. When you run terraform plan and apply, it uses this terraform provider in the .terraform folder to communicate with AWS APIs in order to provision your resources. So in order to connect to the AWS cloud and provision your resources, you need to have added and downloaded the AWS provider. Providers are distributed separately from Terraform with its own release cycles and version numbers.  
In AWS provider block, you can specify _profile_ there. So you don't have to keep switching profiles all the time.  
**MULTIPLE PROVIDER CONFIGURATIONS - Alias**  
You can optionally define multiple configurations for the same provider, and select which one to use on a per-resource or per-module basis. The primary reason for this is to support multiple regions for a cloud platform. _provider = aws.london_   
_terraform apply -auto-approve_ to avoid the interruption.  
Whenever you run terraform apply, a terraform.tfstate file gets created for you which is like a database of your terraform resources.  
**DEPENDENCY LOCK FILE**  
Terraform has two external dependencies outside its code base: Providers and Modules. After selecting a specific version of each dependency using version constraints, terraform remembers the decision it made in a dependency lock file so that it can (by default) nake the same decision in the future. If Terraform did not find a dependency lock file, it would download the latest version of the provider that fulfills the version constraints you defined in the required_providers argument inside the terraform block. If we have a lock file, the lock file causes Terraform to always install the same provider version, ensuring that runs across your team or remote sessions would be consistent. This file is created when you run terraform init. But if you run terraform init -upgrade it actually upgrades beyond what's in the lock file.  
**META-ARGUMENTS** can be used with any resource to change the behaviour of the resource for e.g. for_each, provider, count, life_cycle, depends_on. Notice how it is different from resource arguments.  
When you run terraform apply for the first time, terraform.tfstate file is created. When you run the command subsequently, it just updates the state file.
**PRO TIP**  
To view the available parameters for a configuration while using the Terraform VSCode extension, use CTRL + Space.  
When creating an ec2 instance that requires access to the internet maybe using nginx, say you are using a custom VPC, ensure that the IGW has been created before adding the route_to_internet object using **depends_on** Else, you application will only work intermittently


**RESOURCE META-ARGUMENT _count_**  
A resource or module block can contain a count meta-argument whose value is a whole number or a numeric expression. This value must be known before Terraform performs any remote action. _count.index_ gives you the distinct index number of each instance starting from 0. When count is set, terraform distinguishes between the block itself and the multiple resource or module instances associated with it. Instances are identified with their index numbers as such aws_instance.myvm[0]  
A given resource or module block cannot use both count and for_each.  
_terraform apply -auto-approve_    
_terraform destroy -auto-approve_  
**RESOURCE META-ARGUMENT _for_each_**  
If a resource or module block contains a for_each meta-argument whose value is a set of strings or a map, terraform will create one instance for each member of that set or map. In blocks where for_each is set, an additional **each** object is present in expressions, so you can modify the configuration of each instance. _each.key_ and _each.value_ Note that for a set of strings, **each.key = each.value**  
for_each = toset(["Jack", "Peter"])  
for_each = { dev = "my-bucket", prod = "sensitive-bucket" }  

**LIFECYCLE META-ARGUMENT**  
lifecycle is a nested block that appears within a resource block.  
* create_before_destroy
* prevent_destroy
* ignore_changes
  
The default behavior of terraform is to first destroy before recreating. Say you changed the AZ from us-east-1a to us-east-1b.
lifecycle {
  create_before_destroy = true
  }
changes that behavior.
If you have a particularly important resource that you do not want to get accidentally deleted when terraform destroy is run, you can add the lifecycle rule of prevent_destroy = true. But keep in mind that if you delete that resource block and run terraform apply, that resource will be deleted.
So for ignore_changes; let's say there is a quick fix you did on the AWS console or you ran a script that made those changes, normally, the next time you run terraform apply those changes will be reverted to the desired state as seen on your terraform configuration files. But if you don't want those manual changes to be overwritten on some specific arguments, you can add those arguments to be ignored through the _ignore_changes = [tags, name]_
Important Note: Instead of a list, the special keyword _all_ maybe used to instruct Terraform to ignore all attributes, which means that Terraform can create and destroy the remote object but will never propose updates to it.  
**TERRAFORM VARIABLES**  
Terraform variables are of three types:  
* input variables
* output values
* local values
If you don't specify a default value when defining your input variables, Terraform will prompt you to provide a value when you run terraform plan or terraform apply. You can also decide to use -var on the CLI to override default values.
**terraform apply -var="instance_type=t3.micro" -var="instance_count=2"**
Instead of having to provide the CLI values for both plan and apply, this is where the plan output file comes in handy as -out .main.tfplan or whatever you want to name this output file. This way the plan is saved and you can directly apply the plan without having to write out the variables again. It won't even stop to ask you to approve the apply.
**INPUT VARIABLES OVERRIDE WITH ENVIRONMENT VARIABLES**
  Set environment variables on your system that are conformant with Terraform env variables, then run terraform plan to see if it overrides the default value. No one knows these values apart from your local system where you created them. Terraform merely picks these values from your system.
  **export TF_VAR_${variable_name}=value**
  ** Assign Input Variables from terraform.tfvars file**
  If there is a file named terraform.tfvars, Terraform will auto-load the values present in that file and use them to override the default values in variables.tf
  **Assign Input Variables with -var-file **
  If you plan to use a different name for your .tfvars file different from terraform.tfvars, then you need to specify this file name by using -var-file argument on the commandline while running terraform plan or apply. terraform plan -var-file="dev.tfvars"
You can have different .tfvars files for the different environments. Maybe u want test to use instance size of t2.micro, staging to be on a different region or AWS profile, and prod to be in an entirely different AWS account using the profile argument in providers. These are just some of the ways people try to implement namespacing in terraform. If it were Azure, you might be using the concept of resource-groups or subscription. So at the point of running your teraform apply, you pass in whatever represents the variable file for your target environment e.g., terraform apply -var-file="stagiging.tfvars" and you are sure the right resources are deployed into the right environment. Whatever method you want to adopt, ensure you have proper documentation for maintainability.
** AUTO LOAD INPUT VARIABLES WITH .auto.tfvars files**
With this extension, whatever the file name, it will be auto-loaded during terraform plan or apply. You no longer need to pass -var-file argument
**EC2 Instance Size as a variable of type map(string)**
  variable "ec2_instance_type" {
  description = "EC2 Instance Type using maps"
  type = map(string)
  default = {
    "small-apps" = "t3.micro"
    "medium-apps" = "t3.medium" 
    "big-apps" = "t3.large"
  }

# Reference Instance Type from Maps Variables
instance_type = var.ec2_instance_type["small-apps"]    
Another good application would be for tagging the resources in our env with matching tags.  
var "hr_dev_tags" {
  type = map(string)  
  description = "Tags for HR resources in the dev environment."
  default = {
    "Dept" = "HR",
    "env" = "dev"
    }
  }  
tags = var.hr_dev_tags  
 
**TERRAFORM CONSOLE** 
Provides an interactive environment for evaluating terraform expressions. You don't have to test out your expressions by writing it in your configuration files, then applying to view the outcome, thereby messing up your environment continuously. You can run _echo "1 + 5" | terraform console"_ or you just open terraform console directly by running _terraform console_  
**CUSTOM VALIDATION RULES FOR INPUT VARIABLES**  
variable "ec2_ami_id" {
  description = "AMI ID"
  type = string  
  default = "ami-0be2609ba883822ec"
  validation {
    condition = length(var.ec2_ami_id) > 4 && substr(var.ec2_ami_id, 0, 4) == "ami-"
    error_message = "The ec2_ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}  
**PROTECTING SENSITIVE INPUT VARIABLES**  
This is simply achieved by setting _sensitive = true_ within the variables block. But keep in mind that if you set sensitive variables using environment variables on your commandline, those values will still be in your commandline history. Terraform will redact these values in command output and log files, and raise an error when it detects that they will be exposed in other ways. For example, if you are calling your variable somewhere else like in outputs file, it will throw an error. Terraform state file contains values for these sensitive variables terraform.tfstate. You must keep your state file secure to avoid exposing this data.  
**VARIABLE DEFINITION PRECEDENCE**  
The various mechanisms for setting variables can be used together in any combination. If the same variable is assigned multiple values, Terraform uses the last value it finds, overriding any previous values.  
Terraform loads variables in the following order, with later sources taking precedence over earlier ones:

Environment variables
The terraform.tfvars file, if present.
The terraform.tfvars.json file, if present.
Any *.auto.tfvars or *.auto.tfvars.json files are processed in lexical order of their filenames.
Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)  
**file function** reads the contents of a given filepath and returns them as string.  
**TERRAFORM OUTPUT VALUES**  
Output values are like the return values of a terraform module and has several uses:  
1. A root module can use outputs to print certain values to the CLI after terraform apply is run.
2. A child module can use outputs to expose a subset of its attributes to a parent module.
3. WHen using remote state, root module outputs can be accessed by other configurations via a terraform_remote_state data source. Resource instances managed by Terraform each export attributes whose values can be used elsewhere in configuration. Output values are a way to expose some of that information to the user of your module. An output can be marked as containing sensitive material by setting sensitive = true
output "db_password" {
  value       = aws_db_instance.db.password
  description = "The password for logging in to the database."
  sensitive   = true
}
Terraform will hide values marked as sensitive in the messages from terraform plan and terraform apply.
Remember you can easily using template strings with anything you want to interpolate. For example, if you want to output the value of the public DNS of an EC2 instance, you can use a template string as follows:
value = "http://${aws_instance.web-server.public_dns}"
KEEP IN MIND THAT OUTPUT VALUES CAN COME FROM BOTH RESOURCE ATTRIBUTES OR EVEN RESOURCE ARGUMENTS.
If you run _terraform output_ it will display all your output values. It gets those output from the state file. So you don't need to worry about not getting the outputs after running terraform apply. If you want to output a specific value, you can by running terraform output <output_name>
Remember that you can declare an output as sensitive. This way when you run terraform apply its value would be redacted. But if you run terraform output <output_name>, the state file will give you its value in a non-redacted form. You can also get the outputs in a machine-readable json format by running terraform output -json
**LOCAL VALUES**
A local value assigns a name to an expression, so you can use the name multiple times within a module instead of repeating the expression. The expressions in local values are not limited to literal constants; they can also reference other values in the module in order to transform or combine them, including variables, resource attributes, or other local values:
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
Use local values only in moderation, in situations where a single value or result is used in many places and that value is likely to be changed in the future. The ability to easily change the value in a central place is the key advantage of local values.  
**DATA SOURCES**   
Data sources are a way of using resources that exist outside of terraform or outside of the current configuration. For example, using an already existing VPC in your AWS account to deploy your ec2 instance. In this case you don't want to import the VPC to be managed by terraform, rather you just want to reference it to be used by your EC2 instances managed by terraform. It can also be used to read dynamic data. For instance, getting the latest ami id instead of continuously updating a variable or hardcoding its value.  
**TERRAFORM STATE**  
Backends are responsible for storing state and providing an API for state locking. AWS S3 bucket is used for remote state storage while DynamoDB is used for terraform state locking.  
The problem with using local state files is that multiple team members cannot update the infrastructure as they do not have access to the state file. Now when you use S3 as the shared storage for the state file, another challenge would be multiple users making updates(running terraform apply) at the same time as multiple users make concurrent updates to the state file which could lead to conflicts, data loss or state file corruption. This is why we need to implement state locking using DynamoDB. Not all backends support state locking. State locking happens automatically for all operations that could write state. If state locking fails, terraform will not continue. You can disable state locking for most commands with the -lock file but this is not recommended. If acquiring the lock is taking longer than expected, terraform will output a status message. If terraform doesn't output a message, state locking is still occurring. Terraform has a _force-unlock_ command to manually unlock the state if unlocking failed. Terraform apply and terraform destroy are both operations that can write state. Backend is only used by terraform CLI. Terraform Cloud and terraform Enterprise always use their own state storage. So they ignore any backend block in the configuration. For terraform cloud users, it is recommended to still have the backend block cos for some commands like terraform taint, you must use the CLI.  
**TERRAFORM SHOW COMMAND**  
By default, terraform show is used to display the contents of the state file even if it doesn't exist in our local directory, but only exists in the remote state storage. Also, we can use terraform show to read terraform plan output files since they are usually in binary format. Firstly we run terraform plan -out main.tfplan, then terraform show main.tfplan.  
**TERRAFORM REFRESH**  
The terraform refresh command is used in reconciling the state terraform knows (via its state file) with real-world infrastructure. This can be used to detect any drift from the last known state, and to update the state file. This does not modify infrastructure but does modify the state file. In summary, terraform refresh updates the local state file against real-world resources in the cloud. So if there are changes you made manually on your cloud resources, when you run terraform refresh or any command that calls terraform refresh, terraform pulls those changes and updates your state file to reflect the current state of your infrastructure. It doesn't modify your resources or your terraform manifest files, it only focuses on updating your state file. Your desired state is the configurations defined in your .tf files, while your current state are the real resources present in your cloud. Running terraform plan refreshes state, but this action doesn't update the state file. It just stores the new state in memory. But running terraform refresh itself or terraform apply actually updates the state file. So it doesn't update your state file whenever refresh is run. It only updates it or creates a new version if there are any changes made.  
In terraform CICD automation scripts, the workflow is usually, terraform refresh, terraform plan, review execution plan, then apply. The reason for this execution order is to decide whether you want those changes or not. If you do not want those manual changes, simply proceed with terraform apply. But if you do want those changes, refer to the terraform plan output file and incorporate those changes into your .tf configuration files.  
**TERRAFORM STATE COMMAND**  
_terraform state list_ is used to list the resources within a terraform state.  
_terraform state show <..>_ is used to show the attributes of a single resource within a terraform state. eg _terraform state show data.aws_ami.amzn-linux_ _terraform state show aws_instance.my-ec2-vm_  If we are managing a huge infrastructure, these commands will come in handy.  
_terraform state rm_ command is used to remove resources from the terraform state file. This command can be used to remove single resources, single instances of a resource, entire modules, and more. _terraform state rm -dry-run  aws_instance.myec2_  By removing a resource from terraform state, you are saying that you no longer want terraform to manage that resource for you. So if you don't remove that same resource from your configuration file, terraform will create a brand-new resource for it. So the former resource will be a terraform non-managed resource while the new one created will be a terraform managed resource. So if you want a resource to no longer be managed by terraform, you remove it from state using the terraform state rm command.  
_terraform state replace-provider_ replaces the provider that manages your resources. Maybe because ypu have configured your own custom provider.  
**TERRAFORM STATE PULL/PUSH COMMAND**  
This comes under terraform disaster recovery concept. _terraform state pull_ will download the state file from its current location and display it on stdout. _terraform state push_ is used to push your terraform state file from your local to a newly configured remote location.  
**TERRAFORM TAINT AND UNTAINT**  
The _terraform taint_ command usually marks a resource as tainted, forcing it to be destroyed and recreated on the next apply. A practical application would be on an a VM or an EC2 instance that configures itself using a cloud-init script or userdata script. When this script changes, there is usually nothing to tell terraform that this VM no longer meets your need because the script has changed. What you can do is to manually taint this VM and force its destruction and recreation.  
_terraform untaint_ reverses either a manual terraform taint or the result of provisioners failing on a resource. This command does not modify infrastructure, rather modifies the state file in order to mark a resource as untainted.   
**TERRAFORM RESOURCE TARGETTING WITH -target (PLAN & APPLY)**  
The -target option can be used to focus Terraform's attention on only a subset of resources. This targeting capability is provided for exceptional circumstances, such as recovering from mistakes or working around terraform's limitations. terraform plan -target=aws_instance.myec2-web  The target also covers dependent resources of the ec2 instance such as associated security groups. So if there is a change in the SG, the plan will update it.  
**TERRAFORM WORKSPACES**  
Terraform starts with a single workspace named _default_. This workspace is special because it is the default and because it can never be deleted. One use case of workspaces is to create a temporary parallel workspace to freely test out large infrastructure changes without affecting the resources in the default workspace.  
Terraform does not recommend using workspaces for larger infrastructure inline with environment patterns like dev, qa, staging. It is recommended to use separate configuration directories. Terraform CLI workspaces are completely different from Terraform Cloud Workspaces.  
Note that whatever workspace you create will have its own state file. _name = "vpc-ssh-${terraform.workspace}"_  Referencing the current workspace can be useful for changing behaviour based on the current workspace. For example, for non-prod workspace, it might be better to spin up smaller cluster sizes. _count = terraform.workspace == "prod" ? 3 : 1_    
_output value = aws_instance.myec2-vm.*.public_ip_ this is used when you have multiple instance by using count or for_each.   
_terraform workspace list_ lists all available workspaces with the current workspace marked with asterisk. _terraform workspace show_ shows you the current workspace.  
When you have just have the default workspace, you will just have the terraform.tfstate file. But when you start creating additional workspaces, a directory named _terraform.tfstate.d_. This directory will contain sub-directories named according to your additional workspaces. Then inside those workspace folders you have their individual terraform.tfstate files. When you run terraform destroy, it only destroys the resources managed by the current workspace.  
**TERRAFORM PROVISIONERS**  
Provisioners should be used as last resort. First check if there is a provider functionality available for your use-case.  
There are 3 types of provisioners: 
* file provisioners
* remote-exec provisioners
* local-exec provisioners
**CONNECTION BLOCK** Most provisioners require access to the remote resource either via SSH or WinRM and expect a nested connection block with details on how to connect. Expressions in connection block cannot refer to their parent resource by name. Instead, they can use the special _self_ object. The self object represents the provisioner's parent resource, and has all of that resource's attributes.
**File provisioner** is used to copy files from the local machine running Terraform to the remote resource created. You can copy a file, a directory, or even just a string expression generated and this will be saved into a file in the remote resource.
**Local-exec Provisioner** invokes a local executable after a resource is created. This invokes a process on the machine running terraform, not on the resource. It could be run on creation time or on destroy time. By default, it is creation-time.
**Remote-exec Provisioner** invokes a script on the remote resource after it is created. This can be used to run a configuration management tool, bootstrap into a cluster, etc.
**Null_Resource & Provisioners**
If you need to run provisioners that aren't associated with a specific resource, associate them with a null_resource. You might want to do this because if you make a change to a provisioner, the associated resource will also be affected.
There are creation-time and destruction-time provisioners. By default, provisioners are run when the resources associated with them are created. You don't need to write any configuration for it. If you want your provisioner to be triggered when your resource is destroyed, add the argument _when = destroy_. If a creation-time provisioner fails, the resource is marked as tainted. By default, provisioners that fail will also cause the terrraform apply itself to fail. You can change this behaviour by setting the _on_failure_ argument. It is either continue or fail. e.g _on_failure = fail_. _continue_: ignore the error and continue with the creation or destruction. _fail_: (default behaviour) raise an error and stop applying. If this is a creation time provisioner, taint the resource.
To check if a resource has been tainted, search the state file for the word taint.
**NULL PROVIDER**
The null provider is a rather-unusual provider that has constructs that intentionally do nothing. This may sound strange and most times you don't have to use them. But they can come in handy in tricky situations or used to overcome certain limitations. It makes your terraform configuration harder to understand and should only be used as a last resort. You need to add the null provider before you can use the null_resource. 99% of the time, what you use the null_resource for is for attaching to a provisioner. Say you have a provisioner that you do not want to associate with any actual resource, you can create a null resource for it. This job doesn't need to be part of the real resource.
Using a time provider together with a null resource can help you perform an action for instance update a file, on a resource (eg an ec2 instance) without disrupting the instance or impacting existing services. So you can just connect using a provisioner and update your files.
You can use
triggers = {
  always-update = timestamp()
}
to force the null_resource to always run during each terraform apply. Time provider using time_sleep resource can help you sleep for like 90secs after your ec2 instance is created to ensure that the apache server is installed before trying to copy files to it. You have to use the depends_on to attach to the ec2 instance. Then the null resource that holds the file provisioner that copies the static file to the /var/www/html location will also have the depends_on associated with the time_sleep resource. So this way u can update the static content of the apache server without disturbing the uptime of the ec2 instance.
**TERRAFORM MODULES**
Modules are containers for multiple resources that are used together. A module consists of multiple .tf files kept together in a directory. For example, you could have an EC2 module that contains all the resources needed to successfully run an ec2 instance and using the company standard. Every terraform configuration has at least one module, known as the root module, which consists of the resources defined in the .tf files in the main working directory.A terraform module, usually the root module can call other modules to include their resources into its configuration. In addition to modules from the local file system, terraform can load modules from a public or private registry. 
