
# Create CloudStack instance using Terraform

Create instances of CloudStack more easily with Terraform.

## Prerequisites

- Download Terraform 1.24 version and set global variables

## Deploy Using the Terraform CLI

### Clone the Module
Create a local copy of this repository:

    git clone https://github.com/ZConverter/cloudstack-terraform.git
    cd cloudstack-terraform
    ls

### Set Up and Configure Terraform

1. Create a `terraform.json` file, and specify the following variables:

```
# Authentication
{
	"generate": {
		"cloud_platform": "cloudstack",
		"auth": {
			"api_url" : null,
			"api_key" : null,
			"secret_key" : null
		},
		"vm_info": {
			"vm_name" : null,
			"service_offering" : null,
			"template" : null,
			"zone" : null,
			"project" : null,
			"affinity_group_names" : null,
			"root_disk_size" : null,
			"network_id" : null,
			"security_group_names" : null
		}
	}
}
````

### Create the Resources
Run the following commands:

    terraform init
    terraform plan -var-file=terraform.json
    terraform apply -var-file=terraform.json -auto-approve

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy -var-file=terraform.json -auto-approve
