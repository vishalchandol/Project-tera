output "pub_sg_ids" {
  value = aws_security_group.sg1[*].id
}

output "pub_sub_id" {
  value = aws_subnet.pubsub[*].id
}