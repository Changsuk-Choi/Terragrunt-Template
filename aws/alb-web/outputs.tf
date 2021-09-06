output "dns_name" {
  value = aws_alb.web.dns_name
}

output "zone_id" {
  value = aws_alb.web.zone_id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "alb_arn" {
  value = aws_alb.web.arn
}

output "alb_arn_suffix" {
  value = aws_alb.web.arn_suffix
}

output "target_group_arn" {
  value = aws_alb_target_group.web.arn
}

output "target_group_a_arn_suffix" {
  value = aws_alb_target_group.web.arn_suffix
}
