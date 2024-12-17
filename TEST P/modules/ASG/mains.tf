
resource "aws_launch_template" "mytemp1" {
  name_prefix = "my-temp-1"
  image_id = "ami-00224e59617d0d55e"
  instance_type = "t2.micro"
  user_data = base64encode(file("${path.module}/web.sh"))
  key_name = "my-key-temp"


  network_interfaces {
    
    associate_public_ip_address = true
    security_groups = var.sgtemp
  }
tags = {
  
}
}

resource "aws_autoscaling_group" "ASG-tf" {
  launch_template {
    version = "$Latest"
    id = aws_launch_template.mytemp1.id
  }
  vpc_zone_identifier = var.asg-sub
  min_size = 1
  max_size = 2
  desired_capacity = 1
  target_group_arns = var.tglb
health_check_type = "EC2"
health_check_grace_period = 300

tag {
  key = "Name"
  value = "Webserver-asg"
  propagate_at_launch = true
}

}

data "aws_instances" "web_server_instances" {
  filter {
    name   = "tag:Name"
    values = ["Webserver-asg"]
  }

  # Make sure to filter by the VPC zone and other identifiers if needed
}

# Output the public IPs of the instances
output "public_ips" {
  value = data.aws_instances.web_server_instances.public_ips
}