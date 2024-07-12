variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]
}

variable "availability_zones" {
  description = "List of availability zones to be used"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "az_count" {
  description = "Number of availability zones to be used"
  type        = number
  default     = 2
}
