resource "aws_iam_policy" "ssm-access-ec2" {
  name        = "SSM-Access-Policy"
  description = "Provides permission to access SSM"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:DescribeEffectivePatchesForPatchBaseline",
            "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetPatchBaseline",
            "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
            "Effect": "Allow",
            "Action": "tag:GetResources",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:DescribePatchBaselines",
            "Resource": "*"
        }
    ]
  }
  )
}


#Create an IAM Role

resource "aws_iam_role" "ssm-role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#Attach the policy to role
resource "aws_iam_policy_attachment" "ssm-attach" {
  name       = "ssm-attachment"
  roles      = [aws_iam_role.ssm-role.name]
  policy_arn = aws_iam_policy.ssm-access-ec2.arn
}

#Create an instance profile using the role
resource "aws_iam_instance_profile" "ssm-profile" {
  name = "ssm"
  role = aws_iam_role.ssm-role.name
}
