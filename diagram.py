from diagrams import Diagram, Cluster
from diagrams.aws.network import VPC, ALB, PrivateSubnet, PublicSubnet, NATGateway
from diagrams.aws.compute import EC2AutoScaling, EC2
from diagrams.aws.management import SystemsManager
from diagrams.aws.security import IAMRole
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb

with Diagram("HA Web Application Architecture", show=False, direction="TB"):
    s3 = S3("Terraform State S3 Bucket")
    dynamodb = Dynamodb("State Lock Table")

    with Cluster("VPC"):
        with Cluster("Public Subnets"):
            alb = ALB("Application Load Balancer")
            nat = NATGateway("NAT Gateway")
        with Cluster("Private Subnets"):
            asg = EC2AutoScaling("Auto Scaling Group")
            ec2_1 = EC2("App Instance 1")
            ec2_2 = EC2("App Instance 2")
            asg >> [ec2_1, ec2_2]
        alb >> asg
        ssm = SystemsManager("AWS SSM")
        iam = IAMRole("EC2 SSM Role")
        [ec2_1, ec2_2] >> ssm
        iam >> [ec2_1, ec2_2]

    # Show Terraform backend components outside VPC
    from diagrams.generic.compute import Rack
    tf_cli = Rack("Terraform CLI")
    tf_cli >> [s3, dynamodb]
