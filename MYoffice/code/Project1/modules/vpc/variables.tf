variable "env" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "cidr_block" {
  type = string

}

variable "pubsub_cidr" {
  type = list(string)
}

variable "privsub_cidr" {
  type = list(string)
}

variable "az" {
  type = list(string)
}



