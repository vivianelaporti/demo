variable "linode_token" {}
variable "linode_public_key" {}
variable "linode_private_key" {}

variable "datadog_agent_key" {}

resource "random_string" "password" {
  length = 32
  special = true
  upper = true
  lower = true
  number = true
}
