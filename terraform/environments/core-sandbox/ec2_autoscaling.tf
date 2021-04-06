resource "aws_autoscaling_group" "cluster-scaling-group" {
  vpc_zone_identifier = sort(data.aws_subnet_ids.shared-private.ids)
  desired_capacity = var.ec2_desired_capacity
  max_size         = var.ec2_max_size
  min_size         = var.ec2_min_size

  launch_template {
    id      = aws_launch_template.ec2-launch-template.id
    version = "$Latest"
  }
}

# EC2 Security Group
# Controls access to the EC2 instances

resource "aws_security_group" "cluster_ec2" {
  name        = "${var.app_name}-cluster-ec2-security-group"
  description = "controls access to the cluster ec2 instance"
  vpc_id      = data.aws_vpc.shared.id

  ingress {
    protocol  = "tcp"
    from_port = 7001
    to_port   = 7001
    cidr_blocks = concat(
      var.cidr_access
    )
  }

  ingress {
    protocol  = "tcp"
    from_port = 32768
    to_port   = 65535
    security_groups = [
      aws_security_group.load_balancer_security_group.id
    ]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = local.tags
}

# EC2 launch template - settings to use for new EC2s added to the group
# Note - when updating this you will need to manually terminate the EC2s
# so that the autoscaling group creates new ones using the new launch template

resource "aws_launch_template" "ec2-launch-template" {
  name_prefix   = var.app_name
  image_id      = var.ami_image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  ebs_optimized = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.cluster_ec2.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 30
      volume_type           = "gp2"
      iops                  = 0
    }
  }

  user_data = base64encode(data.template_file.launch-template.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(map(
      "Name", "${var.app_name}-ecs-cluster",
    ), local.tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(map(
      "Name", "${var.app_name}-ecs-cluster",
    ), local.tags)
  }

  tags = merge(map(
    "Name", "${var.app_name}-ecs-cluster-template",
  ), local.tags)
}

# Datafile to generate the user-data for the EC2

data "template_file" "launch-template" {
  template = file("${path.module}/templates/user-data.sh")
  vars = {
    cluster_name = "${var.app_name}-cluster"
    efs_id       = aws_efs_file_system.opa-18-storage.id
  }
}

# IAM Role, policy and instance profile (to attach the role to the EC2)

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.app_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.app_name}-ec2-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ec2_instance_policy" {
  name = "${var.app_name}-ec2-instance-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_instance_policy.arn
}
