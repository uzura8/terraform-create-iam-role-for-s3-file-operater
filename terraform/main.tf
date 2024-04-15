variable "user_name" {}
variable "bucket_name" {}
#variable "target_keys" {
#  type = list(string)
#}

variable "target_key" {
  description = "target key"
  type        = string
  default     = ""
}

variable "accept_ips" {
  type    = list(string)
  default = []
}


terraform {
  backend "s3" {
  }
}

resource "aws_iam_user" "s3_uploader" {
  name = var.user_name
}

resource "aws_iam_access_key" "s3_uploader_key" {
  user = aws_iam_user.s3_uploader.name
}

resource "aws_iam_policy" "s3_uploader_policy" {
  name = "${var.user_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowListAllBuckets",
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
        #Condition = {
        #  IpAddress = {
        #    "aws:SourceIp" = var.accept_ips
        #  }
        #}
      },
      {
        Sid    = "AllowListBucketContents",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}"
        ],
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "*",
              "${var.target_key}/*",
            ]
          }
          #IpAddress = {
          #  "aws:SourceIp" = var.accept_ips
          #}
        }
      },
      {
        Sid    = "AllowSpecificPathOperations",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/${var.target_key}*",
        ]
        #Condition = {
        #  IpAddress = {
        #    "aws:SourceIp" = var.accept_ips
        #  }
        #}
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach" {
  user       = aws_iam_user.s3_uploader.name
  policy_arn = aws_iam_policy.s3_uploader_policy.arn
}

output "access_key" {
  value     = aws_iam_access_key.s3_uploader_key.id
  sensitive = false
}

output "secret_key" {
  value     = aws_iam_access_key.s3_uploader_key.secret
  sensitive = true

}

