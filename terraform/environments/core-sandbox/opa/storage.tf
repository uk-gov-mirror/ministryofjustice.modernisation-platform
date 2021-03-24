resource "aws_efs_file_system" "opa-18-storage" {
  encrypted        = true
  performance_mode = "generalPurpose" # we may want to change to "maxIo"
  # throughput_mode and provisioned_throughput_in_mibps we may want to set (default is bursting)
  tags = local.tags
}

resource "aws_efs_mount_target" "opa-18-mount" {
  file_system_id = aws_efs_file_system.opa-18-storage.id
  subnet_id      = var.subnet_a
  security_groups = [
    aws_security_group.opa-18-efs-security-group.id
  ]
}

resource "aws_efs_mount_target" "opa-18-mount_B" {
  file_system_id = aws_efs_file_system.opa-18-storage.id
  subnet_id      = var.subnet_b
  security_groups = [
    aws_security_group.opa-18-efs-security-group.id
  ]
}

resource "aws_efs_mount_target" "opa-18-mount_C" {
  file_system_id = aws_efs_file_system.opa-18-storage.id
  subnet_id      = var.subnet_c
  security_groups = [
    aws_security_group.opa-18-efs-security-group.id
  ]
}

resource "aws_security_group" "opa-18-efs-security-group" {
  name_prefix = "opahub18-efs-security-group"
  description = "allow inbound access from container instances"
  vpc_id      = var.vpc_id

  // Allow inbound access from container instances
  ingress {
    protocol  = "tcp"
    from_port = 2049
    to_port   = 2049
    cidr_blocks = [
      var.cidr_block
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

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}
