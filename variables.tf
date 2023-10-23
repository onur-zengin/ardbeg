variable "resource_group_location" {
  type        = string
  default     = "uksouth"
  description = "Location of the resource group. Default:London"
}

variable "system_node_count" {
  type        = number
  description = "The initial quantity of nodes for the system node pool."
  default     = 1
}

variable "user_node_count" {
  type        = number
  description = "The initial quantity of nodes for the user node pool."
  default     = 1
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "ardbegadmin"
}