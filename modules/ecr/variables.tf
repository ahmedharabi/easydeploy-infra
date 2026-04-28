variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning when images are pushed"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow deleting repository even if it contains images"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the repository"
  type        = map(string)
  default     = {}
}
