variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type =  string
}

variable "tags" {
  description = "tags for resources"
  type = map(string)
}

variable "private_sub_cidr" {
    description = "cidr for private subnet"
    type = list(string)

}
variable "public_sub_cidr"{
    description = "cidr of public subnets"
    type = list(string)
}
variable "availability_zone" {
  description = "AZ for subnets"
  type = list (string)
}
