resource "aws_alb" "web" {
  name            = "alb-${local.name}"
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_common_ids
  internal        = false
  security_groups = [ aws_security_group.web.id ]

  tags = var.tags

  dynamic "access_logs" {
    for_each = var.stage != "dev" ? [1] : []
    content {
      bucket  = var.logging_bucket
      prefix  = "alb/alb-${local.name}"
      enabled = true
    }
  }
}

resource "aws_alb_target_group" "web" {
  name                 = "trg-${local.name}"
  port                 = "80"
  protocol             = "HTTP"
  target_type          = var.target_type
  deregistration_delay = 180
  slow_start           = 30
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 15
    interval            = 30
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}
