variable "AWS_REGION" {
  type        = string
  default     = "ap-northeast-2"
  description = "The region in which AWS resources will be created"
}

variable "ENVIRONMENT" {
  type    = string
  default = ""
}