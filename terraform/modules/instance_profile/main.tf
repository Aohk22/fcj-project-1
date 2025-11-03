// user defines assume role policy and permission policies.
resource "aws_iam_role" "this_role" {
  name               = var.iam_role_name
  assume_role_policy = var.assume_role_policy_json
}

resource "aws_iam_policy" "this_policy" {
  name   = var.iam_policy_name
  policy = var.permission_policy_json
}

resource "aws_iam_role_policy_attachment" "this_attachment" {
  role       = aws_iam_role.this_role.name
  policy_arn = aws_iam_policy.this_policy.arn
}

// connector from ec2 service to iam role policies.
resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name
  role = aws_iam_role.this_role.name
}
