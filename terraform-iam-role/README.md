# Create IAM Policy for deployment by pike

## System

### Requirements

- Terraform = 1.7.2
- aws-cli >= 1.27.X

## Deploy

### Install tools

Install terraform on mac

```bash
brew install tfenv
tfenv install 1.7.2
tfenv use 1.7.2
```

Install pike on mac

```bash
brew tap jameswoolfenden/homebrew-tap
brew install jameswoolfenden/tap/pike
```

### Deploy AWS Resources by Terraform

#### 1. Edit Terraform config file

Copy sample file and edit variables for your env

```bash
cd (project_root_dir)/terraform-iam-role
cp terraform.tfvars.sample terraform.tfvars
vi terraform.tfvars
```

### 2. Create Target Role on AWS Console

Example name `create-s3-file-operator-role`
Update `信頼関係` like below

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::your-aws-account-id:user/admin-base-user"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

### 3. Set AWS Profile

##### If use aws profile

```bash
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=your-aws-profile-name
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
      "Resource": ["arn:aws:iam::your-aws-account-number:policy/*"]
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
      "Resource": ["arn:aws:iam::your-aws-account-number:role/*"]
    }
  ]
}
```

### 3. Execute terraform init

```bash
terraform init
```

### 4. Execute terraform apply

```bash
terraform apply -auto-approve -var-file=./terraform.tfvars
```

### 5. AWS-Vault Config

```bash
vi ~/.aws/config
```

## For Development

If you need to create definition, execute as below

Create Terraform file to create IAM policy

```bash
cd (project_root_dir)/terraform-iam-role
pike scan -d ../terraform -i -e > var/role.tf
```

Edit generated file

```bash
vi var/role.tf main.tf terraform.tfvars
```

And Edit other Action and Resource for your env

If use aws-vault
