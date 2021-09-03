resource "aws_eip" "nat" {
  count = length(var.azones)

  vpc = true

  tags = merge(
    var.tags,
    tomap(
      {
        "Name" = format("eip-%s-nat-%s",
          var.name,
          substr(var.azones[count.index], -1, 1)
        )
      }
    )
  )
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.azones)

  subnet_id     = var.subnet_ids[count.index]
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(
    var.tags,
    tomap(
      {
        "Name" = format("nat-%s-%s",
          var.name,
          substr(var.azones[count.index], -1, 1)
        )
      }
    )
  )
}
