resource "aws_subnet" "subnet" {
  count             = length(var.cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.cidrs[count.index]
  availability_zone = var.azones[count.index]

  tags = merge(
    var.tags,
    tomap(
      {
        "Name" = format("snet-%s-%s-%s",
          var.name,
          var.type,
          substr(var.azones[count.index], -1, 1)
        )
      }
    )
  )
}
