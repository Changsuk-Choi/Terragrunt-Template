module "public_subnet_common" {
  source = "./subnet"

  vpc_id = aws_vpc.vpc.id
  cidrs  = var.public_subnet_common_cidrs
  azones = var.availability_zones
  type   = "common"

  tags = var.tags
  name = local.name
}

module "nat_subnet_api" {
  source = "./subnet"

  vpc_id = aws_vpc.vpc.id
  cidrs  = var.nat_subnet_api_cidrs
  azones = var.availability_zones
  type   = "api"

  tags = var.tags
  name = local.name
}

module "private_subnet_cache" {
  source = "./subnet"

  vpc_id = aws_vpc.vpc.id
  cidrs  = var.private_subnet_cache_cidrs
  azones = var.availability_zones
  type   = "cache"

  tags   = var.tags
  name   = local.name
}

module "private_subnet_db" {
  source = "./subnet"

  vpc_id = aws_vpc.vpc.id
  cidrs  = var.private_subnet_db_cidrs
  azones = var.availability_zones
  type   = "db"

  tags = var.tags
  name = local.name
}

module "route_table" {
  source = "./route-table"

  vpc_id            = aws_vpc.vpc.id
  igw_id            = aws_internet_gateway.igw.id
  ngw_ids           = module.nat_gateway.ids
  public_subnet_ids = module.public_subnet_common.ids
  nat_subnet_ids    = module.nat_subnet_api.ids
  cache_subnet_ids  = module.private_subnet_cache.ids
  db_subnet_ids     = module.private_subnet_db.ids
  aws_region        = var.aws_region

  tags = var.tags
  name = local.name
}

module "nat_gateway" {
  source = "./nat-gateway"

  azones     = var.availability_zones
  subnet_ids = module.public_subnet_common.ids

  tags = var.tags
  name = local.name
}

module "vpc_endpoint" {
  source = "./vpc-endpoint"

  vpc_id     = aws_vpc.vpc.id
  nat_rt_ids = module.route_table.nat_ids
  aws_region = var.aws_region

  tags = var.tags
  name = local.name
}
