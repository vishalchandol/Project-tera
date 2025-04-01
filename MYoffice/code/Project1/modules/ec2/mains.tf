

provider "aws" {

}

resource "aws_instance" "inst1" {
  instance_type = "t2.micro"
  #ami = "ami-00224e59617d0d55e"
  #ami = "ami-015612a97cb1d6952"
  ami = "ami-071226ecf16aa7d96"
 
  subnet_id = var.sub_id[0]
  associate_public_ip_address = true
  tags = {
    name = "${var.env}inst"
  }

  vpc_security_group_ids = var.sg-inst
  source_dest_check = false
 # key_name = aws_key_pair.kp1.key_name

}

