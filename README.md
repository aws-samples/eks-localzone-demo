# eks-localzone-demo 

This project contains Terraform infrastructure as code for deploying a sample, highly resilient, multi-region application running on Amazon EKS and other AWS services.  It contains the companion source code for the Architecting for Resiliency using AWS App Runner blog post.  The IaC code is written in Terraform and the application code is written in Go and Next.js.

It contains the companion source code for the [Workload on EKS in Local Zones with resilient architecture]().  The IaC code is written in Terraform.


## Usage

1. Clone this git repository

2. Update the Terraform input variables by editing the file `demo.auto.tfvars`

3. Go to each folder from 01-vpc to 05-route53 the run `terrafrom init` and `terraform apply` 

4. Go to the `06-kubernetes` and run `kubectl apply -k .` 

At this point, you should have an application running in whichever two AWS regions you set in the `terraform.tfvars` files.

If you wish to tear down the application, you can run `terraform destroy` to deprovision the resources that were created in your AWS account.

### Deployment

The following are the minimum required dependencies needed to deploy the solution.

- AWS CLI v2
- Terraform >= v1
- jq
- kubectl
