output "nat_ids" {
  value = aws_route_table.nat.*.id
}
