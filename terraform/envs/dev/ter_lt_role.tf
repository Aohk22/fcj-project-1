# IAM Role
resource "aws_iam_role" "ec2-dynamodb-role" {
  name = "ec2-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "dynamodb-access" {
  name        = "dynamodb-access-policy"
  description = "Allow EC2 to interact with DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-dynamodb-policy" {
  role       = aws_iam_role.ec2-dynamodb-role.name
  policy_arn = aws_iam_policy.dynamodb-access.arn
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2-dynamodb-profile" {
  name = "ec2-dynamodb-profile"
  role = aws_iam_role.ec2-dynamodb-role.name
}
