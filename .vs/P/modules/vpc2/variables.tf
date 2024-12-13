variable "secret_key" {
  default = "ZKiYSvS9ExeQexGXlPHfjRjZJvQf/fixJzoXGzh6"
  type = string 
  sensitive = true

}

variable "access_key"{
    default = "AKIAY5BIKONZ5PIRWJJE"
    type = string
    sensitive = true
}

variable "cidr_block" {
  default = "11.0.0.0/16"
  type = string
  
}

variable "tags" {
  type = map (string)
}

variable "pubsub_cidr" {
  type = list(string)
}

variable "availability_zone" {
    description = "AZ for public subnets"
  type = list(string)
}

variable "privsub_cidr" {
  type = list(string)
}

variable "availability_zone_priv" {
    description = "AZ for private subnets"
  type = list(string)
}

