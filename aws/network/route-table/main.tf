resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  # Why did comment out "route"?
  # Terraform currently provides both a standalone Route resource and a Route Table resource with routes defined in-line.
  # At this time you cannot use a Route Table with in-line routes in conjunction with any Route resources.
  # Doing so will cause a conflict of rule settings and will overwrite rules.

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = var.igw_id
  # }

  tags = merge(
    var.tags,
    tomap( { "Name" = "rot-${var.name}-public" } )
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id

  depends_on = [ aws_route_table.public ]
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "nat" {
  count = length(var.ngw_ids)

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    tomap( { "Name" = "rot-${var.name}-nat-${format("%02d", count.index + 1)}" } )
  )
}

resource "aws_route" "nat" {
  count = length(var.ngw_ids)

  route_table_id         = element(aws_route_table.nat.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.ngw_ids[count.index]

  depends_on = [ aws_route_table.nat ]
}

resource "aws_route_table_association" "nat" {
  count = length(var.nat_subnet_ids)

  subnet_id      = var.nat_subnet_ids[count.index]
  route_table_id = element(aws_route_table.nat.*.id, count.index)
}

resource "aws_route_table" "private_cache" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    tomap( { "Name" = "rot-${var.name}-cache" } )
  )
}

resource "aws_route_table_association" "private_cache" {
  count = length(var.cache_subnet_ids)

  subnet_id      = var.cache_subnet_ids[count.index]
  route_table_id = aws_route_table.private_cache.id
}

resource "aws_route_table" "private_db" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    tomap( { "Name" = "rot-${var.name}-db" } )
  )
}

resource "aws_route_table_association" "private_db" {
  count = length(var.db_subnet_ids)

  subnet_id      = var.db_subnet_ids[count.index]
  route_table_id = aws_route_table.private_db.id
}

resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  subnet_ids = flatten([
    var.public_subnet_ids,
    var.nat_subnet_ids,
    var.cache_subnet_ids,
    var.db_subnet_ids
  ])

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    var.tags,
    tomap( { "Name" = "nacl-${var.name}" } )
  )
}
