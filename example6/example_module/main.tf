variable "input_string" {
  description = "Input String"
  type        = string
  default     = null
}

output "output_string" {
    value = var.input_string
}