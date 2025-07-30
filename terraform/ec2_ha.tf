# High Availability EC2 deployment with Auto Scaling Group and Application Load Balancer
# Launch template for EC2 instances (using SSM, no SSH key)
resource "aws_launch_template" "app" {
  name_prefix   = "app-ha-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }
  vpc_security_group_ids = [aws_security_group.app.id]
  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
  # No key_name for SSH, only SSM access

  # Automatically install Docker and run an example container on instance boot
  user_data = base64encode(<<-EOF
  #!/bin/bash
  set -e
  for i in {1..12}; do
  if curl -s --head http://archive.ubuntu.com/ubuntu/ | grep "200 OK" > /dev/null; then
    echo "Connection OK"
    break
  else
    echo "Waiting for network connection..."
    sleep 5
  fi
  done
  apt-get update -y
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
  sleep 15
  docker run -d --name myapp -p 80:80 nginxdemos/hello
EOF
  )
}

# Auto Scaling Group across private subnets (HA)
resource "aws_autoscaling_group" "app" {
  depends_on = [ module.vpc ]
  name                = "app-ha-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.private_subnets
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 60
  target_group_arns         = [aws_lb_target_group.app.arn]
  tag {
    key                 = "Name"
    value               = "${local.tags.Name}-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer in public subnets
resource "aws_lb" "app" {
  name               = "app-ha-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
  tags               = local.tags
}

# Target group for the application
resource "aws_lb_target_group" "app" {
  name     = "app-ha-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 120
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = local.tags
}

# Listener for the ALB
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Security group for EC2 instances (allow HTTP from ALB only)
resource "aws_security_group" "app" {
  name        = "${local.tags.Name}-SG"
  description = "Allow HTTP from ALB only"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# Security group for ALB (allow HTTP from anywhere)
resource "aws_security_group" "alb" {
  name        = "${local.tags.Name}-ALB-SG"
  description = "Allow HTTP from the Internet"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# Output ALB DNS name for access
output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "DNS name of the Application Load Balancer"
}
