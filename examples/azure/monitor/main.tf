module "monitor" {
  source = "git::https://github.com/scalar-labs/scalar-terraform.git//modules/azure/monitor?ref=master"
  # source = "../../../modules/azure/monitor"

  # Required Variables (Use remote state)
  network   = local.network
  cassandra = local.cassandra
  scalardl  = var.scalardl

  # Optional Variables
  base    = var.base
  monitor = var.monitor

  slack_webhook_url = var.slack_webhook_url
}
