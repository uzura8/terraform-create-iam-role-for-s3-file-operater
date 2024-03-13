variable "user_name" {}
variable "bucket_name" {}
#variable "target_keys" {
#  type = list(string)
#}

variable "target_key_prd" {
  description = "Production target key"
  type        = string
  default     = ""
}

variable "target_key_dev" {
  description = "Development target key"
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

#resource "aws_iam_policy" "s3_uploader_policy" {
#  name = "${var.user_name}-policy"
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = concat(
#      [
#        {
#          Sid      = "AllowStatementCommon1",
#          Effect   = "Allow",
#          Action   = ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
#          Resource = ["arn:aws:s3:::*"],
#        },
#        {
#          Sid      = "AllowStatementCommon2",
#          Effect   = "Allow",
#          Action   = ["s3:ListBucket"],
#          Resource = ["arn:aws:s3:::${var.bucket_name}/*"],
#        }
#      ],
#      length(var.target_key_prd) > 0 ? [
#        {
#          Sid      = "AllowStatementPrd",
#          Effect   = "Allow",
#          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
#          Resource = ["arn:aws:s3:::${var.bucket_name}/${var.target_key_prd}/*"],
#        },
#      ] : [],
#      length(var.target_key_dev) > 0 ? [
#        {
#          Sid      = "AllowStatementDev",
#          Effect   = "Allow",
#          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
#          Resource = ["arn:aws:s3:::${var.bucket_name}/${var.target_key_dev}/*"],
#        }
#      ] : []
#    ),
#  })
#}

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
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.accept_ips
          }
        }
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
              "${var.target_key_prd}/*",
              "${var.target_key_dev}/*",
            ]
          }
          IpAddress = {
            "aws:SourceIp" = var.accept_ips
          }
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
          "arn:aws:s3:::${var.bucket_name}/${var.target_key_prd}/*",
          "arn:aws:s3:::${var.bucket_name}/${var.target_key_dev}/*"
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.accept_ips
          }
        }
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

