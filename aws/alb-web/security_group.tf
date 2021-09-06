resource "aws_security_group" "web" {
  name        = "alb-${local.name}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${var.project} ${var.env} alb web security group"

  tags = merge(
    var.tags,
    tomap( { "Name" = "alb-${local.name}"} )
  )
}

resource "aws_security_group_rule" "allow_inbound_http" {
  security_group_id = aws_security_group.web.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = var.allow_http_cidr_blocks
  description       = "Allow http traffic"
}

resource "aws_security_group_rule" "allow_outbound_http" {
  security_group_id = aws_security_group.web.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  description       = "Allow http traffic"
}
