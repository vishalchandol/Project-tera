provider "aws" {
  secret_key = "ZKiYSvS9ExeQexGXlPHfjRjZJvQf/fixJzoXGzh6"
  access_key = "AKIAY5BIKONZ5PIRWJJE"
  region = "us-east-1"
  
}

resource "aws_vpc" "vpc1" {
    cidr_block = var.vpc_cidr
    
    tags = var.tags
  
}


/***
cidr_block = "10.0.0.0/16"
    
    tags = {
      Name =  "main-vpc-1"
    }
  
}
***/
  /*** This subnet for ALB internal IPs - since ALB can scale up to 100 nodes hence 
IP block should be having sufficient atleast IPs ***/

resource "aws_subnet" "pub-sub1-vpc1" {
  count = length(var.public_sub_cidr)
vpc_id = aws_vpc.vpc1.id
cidr_block = var.public_sub_cidr[count.index]
availability_zone = var.availability_zone[count.index]
tags = {
  Name = "priv-sub1-vpc1"
}
}
// For ALB purpose as ALB requires 2 subnets (public subnets)
/***
resource "aws_subnet" "pub-sub2-vpc1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.public_sub_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "priv-sub2-vpc2"
  }
}
***/
resource "aws_subnet" "priv-sub-vpc1" {
  count = length(var.private_sub_cidr)
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.private_sub_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
  Name = "priv-sub-vpc1"
}
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "ig1"
  }
}

// route table only -  P U B L I C

resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.vpc1.id
  
  tags = {
    Name = "pub-route-table-vpc1"
  }
}
// route entry in table  

resource "aws_route" "pub-route-entry" {
    gateway_id = aws_internet_gateway.ig1.id
    route_table_id = aws_route_table.pub-route.id
    destination_cidr_block = "0.0.0.0/0"
}

//route table only - P R I V A T E
resource "aws_route_table" "priv-route" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "priv-route-table-vpc1"
  }
}

resource "aws_route" "nat-entry" {
  count = length(var.public_sub_cidr)
  nat_gateway_id =  aws_nat_gateway.ngw[count.index].id
  route_table_id = aws_route_table.priv-route.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rta1_vpc1" {
  count = length(var.public_sub_cidr)
    route_table_id = aws_route_table.pub-route.id
    subnet_id = aws_subnet.pub-sub1-vpc1[count.index].id
    //subnet_id = aws_subnet.pub-sub1-vpc1[count.index].id
}
/***
resource "aws_route_table_association" "rta2_vpc1" {
    count = length(var.public_sub_cidr)
    route_table_id = aws_route_table.pub-route.id
    subnet_id = aws_subnet.pub-sub2-vpc1[count.index].id
}
***/
resource "aws_route_table_association" "rta3_priv" {
  count = length(var.private_sub_cidr)
  route_table_id = aws_route_table.priv-route.id
  subnet_id      = aws_subnet.priv-sub-vpc1[count.index].id
}

resource "aws_main_route_table_association" "Main_route_vpc1" {
  route_table_id = aws_route_table.pub-route.id
  vpc_id = aws_vpc.vpc1.id
}

// Security groups

resource "aws_security_group" "sgg-1-vpc1" {
  name = "sgg-1-vpc1"
  vpc_id = aws_vpc.vpc1.id

  ingress = [ {
    description      = "HTTP"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    
  }]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sgg-2-vpc1-rest" {
  name = "sgg-2-vpc1-rest"
  vpc_id = aws_vpc.vpc1.id

  dynamic "ingress" {
    for_each = [

      {from_port = 80, to_port =80, protocol = "tcp"},
      {from_port = 443, to_port =443, protocol = "tcp"},
      {from_port = 22, to_port =22, protocol = "tcp"}

    ]

   content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
   } 
    
  }
  }

resource "aws_network_acl" "Acl-vpc-1" {
  #  count = length(var.public_sub_cidr)
vpc_id = aws_vpc.vpc1.id
ingress = [{
  protocol = "tcp"
  from_port = 0
  to_port = 0
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
    to_port =   0
      cidr_block = "0.0.0.0/0"

    rule_no =  200
    action =  "allow"
     ipv6_cidr_block: null
  icmp_code: 0
  icmp_type: 0

  }]
#subnet_ids = [ aws_subnet.pub-sub1-vpc1[count.index].id ]
tags = {
  Name = "acl-vpc-1"
}
}

resource "aws_network_acl_association" "nacl-ass" {
  # for_each = toset([aws_subnet.pub_sub1_vpc1[count.index].id,
   # aws_subnet.priv_sub_vpc1.id])  
     count = length(var.private_sub_cidr)

   #subnet_id = each.value
    subnet_id =  aws_subnet.priv-sub-vpc1[count.index].id
  network_acl_id = aws_network_acl.Acl-vpc-1.id

}
resource "aws_network_acl_association" "nacl-ass2" {
  # for_each = toset([aws_subnet.pub_sub1_vpc1[count.index].id,
   # aws_subnet.priv_sub_vpc1.id])  

   #subnet_id = each.value
     count = length(var.public_sub_cidr)

    subnet_id =  aws_subnet.pub-sub1-vpc1[count.index].id
  network_acl_id = aws_network_acl.Acl-vpc-1.id

}


output "vpc_id" {
  value = aws_vpc.vpc1.id
}
// NAT GATEWAY  //

resource "aws_eip" "pub-ip" {
    
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.public_sub_cidr)
  allocation_id = aws_eip.pub-ip.id
  subnet_id = aws_subnet.pub-sub1-vpc1[count.index].id
  
tags = {
  Name = "ngw"
}

depends_on = [ aws_internet_gateway.ig1 ]
}


/***
resource "aws_s3_bucket" "buck1new" {
    bucket = "s2709buck"

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "buck1newver" {
    bucket = aws_s3_bucket.buck1new.id
    versioning_configuration {
        status = "Enabled"
      
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.buck1new.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pub_acc_1" {
bucket = aws_s3_bucket.buck1new.id
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}


resource "aws_dynamodb_table" "tflocks-bucknew" {
name = "tflocks-bucknew"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"
attribute {
  name = "LockID"
  type = "S"

}
}
***/