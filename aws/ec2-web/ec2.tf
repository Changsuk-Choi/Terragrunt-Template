data "template_file" "web" {
  template = file("${path.module}/user_data.sh")

  vars = {
    HOSTNAME = local.hostname
  }
}

resource "aws_iam_instance_profile" "web" {
  name = "iam-${local.hostname}-profile"
  role = data.terraform_remote_state.iam.outputs.ec2_web_role_name
}

resource "aws_instance" "web" {
  count                   = var.instance_number

  subnet_id               = element(
                              data.terraform_remote_state.vpc.outputs.nat_subnet_api_ids,  
                              count.index
                            )
  ami                     = var.ami[var.aws_region]
  instance_type           = var.instance_type
  vpc_security_group_ids  = [ aws_security_group.web.id ]
  iam_instance_profile    = aws_iam_instance_profile.web.name
  user_data               = data.template_file.web.rendered
  monitoring              = false
  ebs_optimized           = false
  disable_api_termination = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ user_data ]
  }

  volume_tags = merge(
    var.tags,
    {
      "Name" = "${local.hostname}${format("%02d", count.index + 1)}"
      "Role" = local.role
    }
  )

  tags = merge(
    var.tags,
    {
      "Name" = "${local.hostname}${format("%02d", count.index + 1)}"
      "Role" = local.role
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "web_recovery" {
  count              = length(aws_instance.web.*.id)

  alarm_name         = "recovery-${local.hostname}${format("%02d", count.index + 1)}"
  namespace          = "AWS/EC2"
  evaluation_periods = "2"
  period             = "60"
  alarm_description  = "This metric auto recovers EC2 instances"
  alarm_actions      = ["arn:${data.aws_partition.current.partition}:automate:${var.aws_region}:ec2:recover"]

  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0.0"
  metric_name         = "StatusCheckFailed_System"

  dimensions = {
    InstanceId = element(aws_instance.web.*.id, count.index)
  }

  depends_on = [ aws_instance.web ]
}

resource "aws_alb_target_group_attachment" "web" {
  count            = length(aws_instance.web.*.id)

  target_group_arn = data.terraform_remote_state.alb.outputs.target_group_arn
  target_id        = element(aws_instance.web.*.id, count.index)
  port             = 80

  depends_on = [ aws_instance.web ]
}
