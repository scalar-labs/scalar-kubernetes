data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "example-scalar-tfstate"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "cassandra" {
  backend = "s3"

  config = {
    bucket = "example-scalar-tfstate"
    key    = "cassandra/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "scalardl" {
  backend = "s3"

  config = {
    bucket = "example-scalar-tfstate"
    key    = "scalardl/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
