resource "aws_security_group" "web" {
  name        = "ec2-${local.hostname}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${var.project} ${var.env} ec2 web security group"

  tags = merge(
    var.tags,
    tomap( { "Name" = "ec2-${local.hostname}" } )
  )
}

resource "aws_security_group_rule" "allow_ssh_from_bespin_to_web" {
  security_group_id = aws_security_group.web.id
  type              = "ingress"
  from_port         = 8222
  to_port           = 8222
  protocol          = "tcp"
  cidr_blocks       = var.bespin_cidrs
  description       = "Bespin SSH"
}

resource "aws_security_group_rule" "allow_http_from_any_to_web" {
  security_group_id        = aws_security_group.web.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.alb.outputs.security_group_id
  description              = "Apache inbound traffic from ALB"
}

resource "aws_security_group_rule" "allow_outbound_to_http_from_web" {
  security_group_id = aws_security_group.web.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  description       = "HTTP output traffic (yum update, etc)"
}

resource "aws_security_group_rule" "allow_outbound_to_https_from_web" {
  security_group_id = aws_security_group.web.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS output traffic (yum update, etc)"
}
