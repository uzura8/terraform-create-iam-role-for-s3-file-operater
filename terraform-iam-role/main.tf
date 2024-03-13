variable "prj_prefix" {}
variable "aws_account_id" {}
variable "target_role_name" {}

resource "aws_iam_policy" "s3_file_operator" {
  name_prefix = join("-", ["terraform_deploy_config", var.prj_prefix])
  path        = "/"
  description = "IAM Policy for S3 File Operator"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachUserPolicy",
          "iam:CreateAccessKey",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:CreateUser",
          "iam:DeleteAccessKey",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:DeleteUser",
          "iam:DetachUserPolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListGroupsForUser",
          "iam:ListPolicyVersions",
          "iam:ListAttachedRolePolicies",
          "iam:SetDefaultPolicyVersion",
          "iam:UpdateAccessKey",
        ],
        "Resource" : [
          "arn:aws:iam::${var.aws_account_id}:*",
          "arn:aws:iam::${var.aws_account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_file_operator_attachment" {
  role       = var.target_role_name
  policy_arn = aws_iam_policy.s3_file_operator.arn
}
