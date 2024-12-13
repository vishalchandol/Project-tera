output "pubsubid" {
  
  value = aws_subnet.pubsub.*.id
}

output "privsubid" {
  value = aws_subnet.privsub.*.id
}

output "vpcid" {
value =   aws_vpc.vpc02.id
}

output "ec2ip" {
  value = aws_instance.inst1.public_ip
}
output "public-lbsg" {
  value = aws_security_group.sg-allow-vpc02.id
}
output "inst-id" {
  value = aws_instance.inst1.id
}
