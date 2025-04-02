provider "aws" {
  region = var.region 
  alias = "aws1"
}


resource "aws_vpc" "vpc1" {
  
cidr_block = var.cidr_block
tags = {
    Name = "${var.env}-vpc"
}

}

resource "aws_subnet" "pubsub" {
    count = length(var.pubsub_cidr)
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.pubsub_cidr[count.index]
  availability_zone = var.az[count.index]
  tags = {
    Name = "${var.env}-pub_sub${count.index}"
  }

}

resource "aws_subnet" "privsub" {
    count = length(var.privsub_cidr)
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.privsub_cidr[count.index]
  availability_zone = var.az[count.index]
  tags = {
    Name = "${var.env}-priv_sub${count.index}"
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.vpc1.id
  
}
#resource "aws_internet_gateway_attachment" "ig1-att" {
 # vpc_id = aws_vpc.vpc1.id
  #internet_gateway_id = aws_internet_gateway.ig1.id

#}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.env}-pubrt" }
}

resource "aws_route" "routes1" {
  route_table_id = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig1.id
}

resource "aws_route_table_association" "rt1-att" {
    count = length(var.pubsub_cidr)
  route_table_id = aws_route_table.rt1.id
  subnet_id = aws_subnet.pubsub[count.index].id
}

resource "aws_security_group" "sg1" {
  vpc_id = aws_vpc.vpc1.id
tags = {
    Name = "${var.env}-pub_sg"

}

}

resource "aws_security_group_rule" "sg1-rules-ing" {
  security_group_id = aws_security_group.sg1.id
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  type = "ingress"
  cidr_blocks = [ "0.0.0.0/0" ]
}
resource "aws_security_group_rule" "sg1-rules-eg" {
  security_group_id = aws_security_group.sg1.id
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  type = "egress"
    cidr_blocks = [ "0.0.0.0/0" ]

}
resource "aws_network_acl" "acl1" {
  vpc_id = aws_vpc.vpc1.id
  
}

resource "aws_network_acl_rule" "acl1-rules" {
    network_acl_id = aws_network_acl.acl1.id
    rule_action = "allow"
    rule_number = 100
    egress = false
    protocol = -1
    cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "acl1-rules-eg" {
    network_acl_id = aws_network_acl.acl1.id
    rule_action = "allow"
    rule_number = 100
    egress = true
    protocol = -1
    cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_association" "acl1-ass" {
    count = length(var.pubsub_cidr)
  subnet_id = aws_subnet.pubsub[count.index].id
  network_acl_id = aws_network_acl.acl1.id
}

