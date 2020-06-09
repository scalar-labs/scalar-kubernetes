data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "cassandra" {
  backend = "local"

  config = {
    path = "../cassandra/terraform.tfstate"
  }
}

