# Outputs to help users access EC2 instances via SSM

# AWS does not expose EC2 instance IDs directly in the aws_autoscaling_group resource.
# To get instance IDs, use the AWS CLI:
# aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names <name> --query "AutoScalingGroups[].Instances[].InstanceId" --output text

output "asg_instance_ids" {
  description = "To get instance IDs, use the AWS CLI:"
  value       = "aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${data.aws_autoscaling_groups.app.names[0]} --query \"AutoScalingGroups[].Instances[].InstanceId\" --output text"
}

output "ssm_command_example" {
  description = "Example AWS CLI command to start SSM session (replace INSTANCE_ID as needed)"
  value       = "aws ssm start-session --target <INSTANCE_ID> --region ${local.region}"
}
