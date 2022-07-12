### EKS running on Local Zone demo 

This project contains Terraform infrastructure as code for deploying a sample, highly resilient, multi-region application running on Amazon EKS and other AWS services. 

It contains the companion source code for the [Workload on EKS in Local Zones with resilient architecture]().  The IaC code is written in Terraform.


## Architecture 

![](images/archiectecture.png)

In the example app, I am going to run a WordPress website as the demo app to run on Amazon EKS. 

The customer facing endpoint is a Route 53 domain (demo.lindarren.com (http://demo.lindarren.com/)) and has a failover policy to the primary site in the local zone (demo.primary.lindarren.com (http://demo.primary.lindarren.com/)) and backup site (demo.backup.lindarren.com (http://demo.backup.lindarren.com/)) in the availability zones in the region. 

When the customer is connecting to the primary site (local zone), the request is served by the application load balancer (ALB) in the local zone, and the backend servers are hosted by Kubernetes pods, running on the self-managed EC2 nodes. The backend database is an EC2 instance with MariaDB installed. 

For the backup site, there is an also an application load balancer (ALB) and Kubernetes pods running on worker nodes in the region. The database is hosted on RDS. We use DMS to replicate data from the EC2 database instance in the local zone to RDS in the region. 

For persistent storage, the PHP application files are stored on the EFS. It is not supported to create EFS targets in the local zone subnets, so I made a few tweaks to make EFS CSI driver DaemonSet in the local zone to mount EFS filesystem for the pod. 


## Prerequisites: 

* An AWS account with the Administrator permissions 
* Installation of AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), kubectl (https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html), eksctl (https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html), Git (https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli), jq (https://stedolan.github.io/jq/).
* A domain name that you own, for example, lindarren.com
* A shell environment. An IDE environment such as Cloud9 or Visual Studio Code is recommended. Please make sure that you configured IAM credentials on your own instead of Cloud9’s temporary credentials.  
* Opt-in Local Zone that you would like to run your workload
* An TLS certificate for web hosting as a resource in AWS ACM. 




## Usage

1. Clone this git repository

2. Update the Terraform input variables by editing the file `demo.auto.tfvars`

3. Go to each folder from 01-vpc to 05-route53 the run `terrafrom init` and `terraform apply` 

4. Go to the `06-kubernetes` and run `kubectl apply -k .` 

At this point, you should have an application running in whichever two AWS regions you set in the `terraform.tfvars` files.

If you wish to tear down the application, you can run `terraform destroy` to deprovision the resources that were created in your AWS account.

