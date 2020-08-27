# General Settings
variable "base" {
  default = "default"
}

variable "monitor" {
  type    = map
  default = {}
}

variable "targets" {
  type = list(string)
  default = [
    "cassandra",
    "scalardl",
  ]
}

# For Alerting Add Slack Webhook
variable "slack_webhook_url" {
  default = ""
}
