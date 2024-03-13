# Document of Terraform to Create S3 File Operate User

## System

### Requirements

#### Common

- Terraform = 1.7.2

## Deploy

### Install tools

Install serverless terraform on mac

```bash
brew install tfenv
tfenv install 1.7.2
tfenv use 1.7.2
```

### Create IAM Policy and Attach to Role

#### Set AWS Role for Create IAM Policy

##### If use aws profile

```bash
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=your-aws-role-for-create-iam-policy
export AWS_REGION="ap-northeast-1"
```

##### if use aws-vault

```bash
export AWS_REGION="ap-northeast-1"
aws-vault exec your-aws-role-for-create-iam-policy
```

The role needs below policies

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:SetDefaultPolicyVersion",
        "iam:ListPolicyVersions",
        "iam:GetPolicyVersion"
      ],
      "Resource": ["arn:aws:iam::your-account-number:policy/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListPolicies",
        "iam:ListAttachedRolePolicies",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy"
      ],
      "Resource": ["arn:aws:iam::your-account-number:role/*"]
    }
  ]
}
```

#### Create Target Role on AWS Console

#### Edit Terraform config file

Copy sample file and edit variables for your env

```bash
cd (project_root_dir)/terraform-iam-role
cp terraform.tfvars.sample terraform.tfvars
vi terraform.tfvars
```

#### Execute terraform apply

```bash
terraform init -backend-config="region=ap-northeast-1" -backend-config="profile=your-aws-profile-name"
terraform apply -auto-approve -var-file=./terraform.tfvars
```

### Create IAM User

- Access to IAM on AWS Console
- Press "Create User"
  - Example: `your-project-s3-file-operator`
- Set user name and finish without setting permission

### Deploy AWS Resources by Terraform

#### Create AWS S3 Bucket for terraform state

Create S3 Buckets like below in ap-northeast-1 region

- **your-serverless-deployment**
  - Store deployment state files by terraform and serverless framework
  - Create directory "terraform/your-project-name"

#### Set AWS Role for Deploy

##### If use aws profile

```bash
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=your-aws-role-for-deploy
export AWS_REGION="ap-northeast-1"
```

##### if use aws-vault

```bash
export AWS_REGION="ap-northeast-1"
aws-vault exec your-aws-role-for-deploy
```

#### 1. Edit Terraform config file

Copy sample file and edit variables for your env

```bash
cd (project_root_dir)/terraform
cp terraform.tfvars.sample terraform.tfvars
vi terraform.tfvars
```

#### 2. Set AWS profile name to environment variable

##### If use aws profile

```bash
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=your-aws-role-for-deploy
export AWS_REGION="ap-northeast-1"
```

##### if use aws-vault

```bash
export AWS_REGION="ap-northeast-1"
aws-vault exec your-aws-role-for-deploy
```

#### 3. Execute terraform init

Command Example to init

```bash
terraform init -backend-config="bucket=your-deployment" -backend-config="key=terraform/your-project/terraform.tfstate" -backend-config="region=ap-northeast-1" -backend-config="profile=your-aws-profile-name"
```

#### 4. Execute terraform apply

```bash
terraform apply -auto-approve -var-file=./terraform.tfvars
```

## Destroy Resources

Destroy for static server resources by Terraform

```bash
cd (project_root/)terraform
terraform destroy -auto-approve -var-file=./terraform.tfvars
```
