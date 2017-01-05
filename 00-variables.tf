variable "name" {
  type        = "string"
  description = "Name of metadata DynomoDB table"
}

variable "global_read_capacity" {
  type        = "string"
  default     = "10"
  description = "Globally read capacity for metadata table"
}

variable "global_write_capacity" {
  type        = "string"
  default     = "5"
  description = "Globally write capacity for metadata table"
}

variable "rest_api_root_uri" {
  type        = "string"
  default     = "api"
  description = "Root URI for metadata query endpoint"
}
