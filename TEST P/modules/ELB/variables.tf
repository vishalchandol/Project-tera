variable "lbname" {
  #  default = "mylb02"
  type = string
}

variable "tgname" {
 #   default = "mytg02"
  type = string
}

variable "vpcid_from_mod" {
  type = string
}

variable "subnetids_from_mod" {
  type = list(string)
}

variable "lbsg" {
  type = list(string)

}
variable "instance_id" {
  type = list(string)
}