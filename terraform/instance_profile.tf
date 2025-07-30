# IAM role and policy for EC2 to allow SSM Session Manager access
resource "aws_iam_role" "ec2_ssm" {
  name               = "ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  tags               = local.tags
}



# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}
