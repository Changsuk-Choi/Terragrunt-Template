resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    tomap( { "Name" = "vpc-${local.name}" } )
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    tomap( { "Name" = "igw-${local.name}" } )
  )
}
