variable "project_id" {
  type = string
}

variable "project_region" {
  type    = string
  default = "europe-west1"
}

//variable "instance_zones" {
//  type    = list(string)
//  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
//}
//
//variable "vault_server_instance_count" {
//  type    = number
//  default = 3
//}
//
//variable "vault_server_instance_type" {
//  type    = string
//  default = "e2-medium"
//}
//
//variable "vault_server_instance_tag" {
//  type    = string
//  default = "vault-server"
//}
//
//variable "vault_server_instance_image" {
//  type = string
//}