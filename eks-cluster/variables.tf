variable "vpc_cidr" {
  description = "VPC CIDR range for Task-Master-Pro EKS Cluster"
  type        = string

}

variable "private_subnets" {
  description = "Private subnet for the project"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet for the project"
  type        = list(string)
}