locals {
  hostname = "${var.project}-${var.env}-${var.stage}-web"
  role     = "WEB"
}
