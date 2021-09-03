output "ids" {
  description = "List of NAT gateway ids"
  value       = aws_nat_gateway.ngw.*.id
}
