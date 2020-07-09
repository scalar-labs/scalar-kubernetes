module "monitor" {
  source = "git::https://github.com/scalar-labs/scalar-terraform.git//modules/azure/monitor?ref=v1.3.0"

  # Required Variables (Use remote state)
  network   = local.network
  cassandra = local.cassandra
  scalardl  = local.scalardl

  # Optional Variables
  base    = var.base
  monitor = var.monitor
}
