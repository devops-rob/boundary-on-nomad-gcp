variable "project_id" {
  type = string
}

variable "project_region" {
  type    = string
  default = "europe-west1"
}

//variable "credentials" {
//  type = string
//}

variable "instance_zones" {
  type    = list(string)
  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}

# Consul
variable "consul_server_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "consul_server_instance_count" {
  type    = number
  default = 3
}

variable "consul_server_instance_image" {
  type = string
}

variable "consul_server_instance_tag" {
  type    = string
  default = "consul-server"
}

# Nomad
variable "nomad_server_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "nomad_server_instance_count" {
  type    = number
  default = 3
}

variable "nomad_server_instance_image" {
  type = string
}

variable "nomad_server_instance_tag" {
  type    = string
  default = "nomad-server"
}

variable "nomad_client_instance_type" {
  type    = string
  default = "e2-medium"
}

variable "boundary_controller_instance_count" {
  type    = number
  default = 3
}

variable "nomad_client_instance_image" {
  type = string
}

variable "nomad_client_instance_tag" {
  type    = string
  default = "nomad-client"
}

variable "whitelist" {
  type    = list(string)
  default = []
}

variable "database_instance_prefix" {
  type    = string
  default = "bong"
}

variable "database_instance_type" {
  type    = string
  default = "db-g1-small"
}

variable "database_instance_version" {
  type    = string
  default = "POSTGRES_13"
}

variable "database_names" {
  type    = list(string)
  default = ["boundary"]
}

variable "consul_master_token" {
  type = string
}