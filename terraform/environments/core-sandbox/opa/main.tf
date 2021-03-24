data "aws_vpc" "shared" {
  tags= {
    "Name" = "${var.networking[0].business-unit}-${local.environment}"
  }
}
data "aws_subnet_ids" "shared-data" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-data*"
  }
}
data "aws_subnet_ids" "shared-private" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-private*"
  }
}
data "aws_subnet_ids" "shared-public" {
  vpc_id = data.aws_vpc.shared.id
  tags = {
    "Name" = "${var.networking[0].business-unit}-${local.environment}-${var.networking[0].set}-public*"
  }
}
