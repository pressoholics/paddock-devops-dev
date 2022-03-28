variable "name" {
  type        = string
  description = "Function name"
}

variable "content" {
  type        = string
  description = "Content file"
}

variable "policy_arns" {
  type        = list(string)
  description = "Aditional policy ARNs"
  default = []
}