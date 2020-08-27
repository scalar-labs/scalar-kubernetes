data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "cassandra" {
  count = contains(var.targets, "cassandra") ? 1 : 0

  backend = "local"

  config = {
    path = "../cassandra/terraform.tfstate"
  }
}

data "terraform_remote_state" "scalardl" {
  count = contains(var.targets, "scalardl") ? 1 : 0

  backend = "local"

  config = {
    path = "../scalardl/terraform.tfstate"
  }
}
