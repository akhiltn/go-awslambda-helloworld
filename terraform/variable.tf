variable "AWS_DEFAULT_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"  # or any default region you prefer
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
  type        = string
  sensitive   = true
}

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key id"
  type        = string
  sensitive   = true
}

