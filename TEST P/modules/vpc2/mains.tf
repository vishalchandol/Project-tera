provider "aws" {
  region = "us-east-1"
  secret_key = var.secret_key
  access_key = var.access_key
}

 resource "aws_vpc" "vpc02" {
   cidr_block = var.cidr_block  # 11.0.0.0/16 
   tags = var.tags 
   
 }

 resource "aws_subnet" "pubsub" {
    count = length(var.pubsub_cidr)
   vpc_id = aws_vpc.vpc02.id
   cidr_block = var.pubsub_cidr[count.index]
   availability_zone = var.availability_zone[count.index]
   tags = {
     Name = "public-subnet"
   }

 }

 resource "aws_subnet" "privsub" {
   count = length(var.privsub_cidr)
   vpc_id = aws_vpc.vpc02.id
   cidr_block = var.privsub_cidr[count.index]
   availability_zone = var.availability_zone[count.index]
   tags ={
    Name = "priv-subnet"
   }
 }

 resource "aws_internet_gateway" "ig1-vpc02" {
   vpc_id = aws_vpc.vpc02.id
   tags = {
     Name = "ig1-vpc02"
   }
 }

 resource "aws_route_table" "rt-pub-vpc02" {
   vpc_id = aws_vpc.vpc02.id

   tags = {
    Name = "rt-pub-vpc02"
   }

 }

 resource "aws_route_table" "rt-priv-vpc02" {
   vpc_id = aws_vpc.vpc02.id

   tags = {
    Name = "rt-priv-vpc02"
   }
 }

 resource "aws_route" "pub-route-entry-02" {
   route_table_id = aws_route_table.rt-pub-vpc02.id
   destination_cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.ig1-vpc02.id

 }
# NOT creating route entry for Private as it will be created by default 

resource "aws_route_table_association" "rt-pub-ass-vpc02" {
    count = length(var.pubsub_cidr)
  route_table_id = aws_route_table.rt-pub-vpc02.id
  subnet_id = aws_subnet.pubsub[count.index].id
}

resource "aws_route_table_association" "rt-priv-ass-vpc02" {
    count = length(var.privsub_cidr)
  route_table_id = aws_route_table.rt-priv-vpc02.id
  subnet_id = aws_subnet.privsub[count.index].id

}

resource "aws_main_route_table_association" "Main_route_vpc02" {
  route_table_id = aws_route_table.rt-pub-vpc02.id
  vpc_id = aws_vpc.vpc02.id
}

resource "aws_security_group" "sg-allow-vpc02" {
  name = "mysg-all-vpc02"
  vpc_id = aws_vpc.vpc02.id

  ingress = [
{
    description = "HTTP"
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
}
  ]
egress = [
  {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
     ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
]

  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg-restr-vpc-02" {
  name = "mysg-restricted-inst"
  vpc_id = aws_vpc.vpc02.id

dynamic "ingress" {
  for_each = [ 
    {from_port = 80, to_port = 80, protocol = "tcp"},
    {from_port = 22, to_port = 22, protocol = "tcp"}
   ]
   content {
     from_port = ingress.value.from_port
     to_port = ingress.value.to_port
     protocol = ingress.value.protocol
     cidr_blocks = ["0.0.0.0/0"] 
   }
}
lifecycle {
  create_before_destroy = true
}
}

resource "aws_network_acl" "nacl-vpc02" {
  #  count = length(var.pubsub_cidr)
  vpc_id = aws_vpc.vpc02.id
 # subnet_ids = [aws_subnet.privsub[count.index].id, aws_subnet.pubsub[count.index].id]
ingress = [{
  protocol = "tcp"
  from_port = 0
  to_port = 65535
  rule_no = 100

  cidr_block = "0.0.0.0/0"
  action = "allow"
  ipv6_cidr_block: null

  icmp_code: 0
  icmp_type: 0
  
}]
  
  egress = [{
    protocol = "tcp"
    from_port = 0
    to_port =   65535
      cidr_block = "0.0.0.0/0"

    rule_no =  200
    action =  "allow"
     ipv6_cidr_block: null
  icmp_code: 0
  icmp_type: 0

  }]

}

resource "aws_network_acl_association" "acl_ass-1" {
    count = length(var.pubsub_cidr)
    network_acl_id = aws_network_acl.nacl-vpc02.id
    
    subnet_id = aws_subnet.pubsub[count.index].id
 
}

resource "aws_network_acl_association" "acl_ass-2" {
    count = length(var.privsub_cidr)
    network_acl_id = aws_network_acl.nacl-vpc02.id
    
    subnet_id = aws_subnet.privsub[count.index].id
 
}


resource "aws_key_pair" "kp1" {
  key_name = "keypair1"
  public_key = file("./id_rsa.pub")
}


data "aws_ami" "ubuntu" {
  most_recent = true
}
resource "aws_instance" "inst1" {
  #ami = "ami-00224e59617d0d55e"
  #ami = "ami-015612a97cb1d6952"
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pubsub[0].id
  associate_public_ip_address = true
  tags = {
    name = "testLin"
  }
  security_groups = [ aws_security_group.sg-allow-vpc02.id]
  key_name = aws_key_pair.kp1.key_name
}
/***
resource "aws_network_interface" "all" {
  #count = length(aws_security_group.sg-allow-vpc02)
  subnet_id =  aws_subnet.pubsub[1].id
  security_groups = [ aws_security_group.sg-allow-vpc02.id ]
  attachment {
    instance = aws_instance.inst1.id
    device_index = 1
  }

  source_dest_check = false
}

resource "aws_network_interface_attachment" "name" {
  instance_id = aws_instance.inst1.id
  network_interface_id = aws_network_interface.all.id
  device_index = 0
}***/
