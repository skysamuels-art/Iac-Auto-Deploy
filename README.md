# samskys-iac

Infrastructure as Code on AWS with a GitOps workflow. Terraform builds the infrastructure, GitHub Actions deploys it on every push to `main`, and Ansible configures the servers.

## What it builds

- A VPC in `us-west-2` with public and private subnets
- A security group and network ACL allowing ports 22, 80 and 443
- An IAM role for the EC2 instances
- 1 master EC2 (Ansible control node)
- 5 worker EC2s (configured by Ansible)

All instances run Ubuntu 24.04 and use the `1pu` key pair.

## How it works

1. Terraform state is stored in an S3 bucket with versioning.
2. State locking uses `use_lockfile = true`. Terraform creates a `.tflock` file in the bucket while it runs, so two runs can't change the state at the same time.
3. Changes are tested locally first, then pushed to GitHub.
4. GitHub Actions runs `terraform init`, `validate`, `plan` and `apply` against the same S3 state.
5. From the master EC2, Ansible connects to the 5 workers to update them and install Apache2 and MySQL.

## Repository structure

```
samskys-iac/
  .gitignore
  .github/workflows/
    terraform.yml       pipeline: runs on every push to main
  terraform/
    providers.tf        AWS provider
    backend.tf          S3 state and state locking
    variables.tf        all settings (region, AMI, key pair, instance type)
    vpc.tf              VPC and subnets
    security.tf         security group and NACL
    iam.tf              EC2 role
    master-ec2.tf       master EC2
    worker-ec2.tf       5 worker EC2s
    outputs.tf          IPs and IDs
```

## Requirements

- AWS account and AWS CLI
- Terraform 1.10 or newer
- An S3 bucket with versioning enabled for the state file
- The `1pu` key pair in `us-west-2`
- GitHub repository secrets: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

## Deploy locally

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Deploy through the pipeline

```bash
git add .
git commit -m "Describe your change"
git push origin main
```

Then watch the run in the repository's **Actions** tab.

## Configure the workers with Ansible

From the master EC2:

```bash
ansible workers -i inventory.ini -m ping
ansible-playbook -i inventory.ini playbook.yml
```

The playbook updates and upgrades each worker, installs Apache2 and MySQL, and prints both versions.

## Clean up

```bash
terraform -chdir=terraform destroy
```
