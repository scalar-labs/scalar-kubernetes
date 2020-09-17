data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "local"

  config = {
    path = "../kubernetes/terraform.tfstate"
  }
}
