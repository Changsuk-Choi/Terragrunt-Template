data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = ["dynamodb:*"]
    effect  = "Allow"
    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids   = var.nat_rt_ids
  policy            = data.aws_iam_policy_document.dynamodb.json

  tags = merge(
    var.tags,
    tomap( { "Name" = "vpce-${var.name}-dynamodb" } )
  )
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = ["s3:*"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::docker-images-prod",
      "arn:aws:s3:::docker-images-prod/*",
      "arn:aws:s3:::prod-*-starport-layer-bucket",
      "arn:aws:s3:::prod-*-starport-layer-bucket/*",
      "arn:aws:s3:::amazonlinux.*.amazonaws.com",
      "arn:aws:s3:::amazonlinux.*.amazonaws.com/*"
    ]
    principals {
      type        = "*"
      identifiers = [ "*" ]
    }
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = var.nat_rt_ids
  policy            = data.aws_iam_policy_document.s3.json

  tags = merge(
    var.tags,
    tomap( { "Name" = "vpce-${var.name}-s3" } )
  )
}
