variable "env" {
  
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "cidr_block" {
  type = string

}

variable "pubsub_cidr" {
  type = list()
}

variable "privsub_cidr" {
  type = list()
}

variable "az" {
  type = list()
}



