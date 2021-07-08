variable "project_id" {
  type        = string
  description = "The GCP Project ID to use."
}

variable "source_image" {
  type        = string
  description = "The GCE source image to build on."
  default     = "ubuntu-2004-focal-v20210623"
}

variable "ssh_username" {
  type        = string
  default     = "packer"
  description = "The user to use for SSH during provisioning."
}

variable "zone" {
  type        = string
  description = "The zone the image will be built in."
}

variable "account_file" {
  type        = string
  description = "The location of your account file."
}

variable "hashicorp_tool" {
  type    = string
  default = "hashistack"
}