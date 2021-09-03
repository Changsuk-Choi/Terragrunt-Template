output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_common_ids" {
  value = module.public_subnet_common.ids
}

output "nat_subnet_api_ids" {
  value = module.nat_subnet_api.ids
}

output "private_subnet_db_ids" {
  value = module.private_subnet_db.ids
}

output "private_subnet_cache_ids" {
  value = module.private_subnet_cache.ids
}
