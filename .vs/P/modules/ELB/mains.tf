
resource "aws_lb" "lb1" {
  name = var.lbname
  load_balancer_type = "application"
  subnets = var.subnetids_from_mod
  security_groups = var.lbsg
  
}

resource "aws_lb_target_group" "tg1" {
    name = var.tgname
   port = 80
   protocol = "HTTP"
   vpc_id = var.vpcid_from_mod

target_type = "instance"
}

resource "aws_lb_target_group_attachment" "tga" {
    count = length(var.instance_id)
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id = var.instance_id[count.index]
  
}

resource "aws_lb_listener" "http-ls" {
  load_balancer_arn = aws_lb.lb1.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg1.arn
      }
    }
  }
}

output "dns_name" {
  value = aws_lb.lb1.dns_name
}