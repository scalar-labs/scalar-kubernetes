# General Settings
variable "base" {
  default = "default"
}

variable "cassandra" {
  type    = map
  default = {}
}

variable "cassy" {
  type    = map
  default = {}
}

variable "reaper" {
  type    = map
  default = {}
}
