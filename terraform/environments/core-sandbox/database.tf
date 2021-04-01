resource "aws_db_instance" "opa18-hub-db" {
  identifier                          = "opa18-hub-db"
  allocated_storage                   = 20
  storage_type                        = "gp2"
  engine                              = "mysql"
  engine_version                      = "5.7.26"
  instance_class                      = "db.t3.large"
  multi_az                            = var.db_multi_az
  name                                = "opa18hubdb"
  username                            = var.db_user
  password                            = var.db_password
  port                                = "3306"
  storage_encrypted                   = false
  iam_database_authentication_enabled = false
  vpc_security_group_ids = [
    aws_security_group.opa18-hub-db.id
  ]
  snapshot_identifier       = var.db_snapshot_identifier
  backup_retention_period   = 30
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  final_snapshot_identifier = "opahub18-final-snapshot"
  deletion_protection       = false
  db_subnet_group_name      = aws_db_subnet_group.opa18-hub-db.id
  option_group_name         = aws_db_option_group.opa18-hub-db.id

  timeouts {
    create = "40m"
    delete = "40m"
    update = "80m"
  }

  tags = local.tags
}

resource "aws_db_subnet_group" "opa18-hub-db" {
  name = "opa18-hub-subnet-group"
  subnet_ids = sort(data.aws_subnet_ids.shared-data.ids)
  tags = local.tags
}

resource "aws_security_group" "opa18-hub-db" {
  name        = "opa18_hub_allow_db"
  description = "Allow DB inbound traffic"
  vpc_id      = data.aws_vpc.shared.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_subnet_ids.shared-private
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_db_option_group" "opa18-hub-db" {
  name                 = "opa18-hub-db-option-group"
  engine_name          = "mysql"
  major_engine_version = "5.7"
}
