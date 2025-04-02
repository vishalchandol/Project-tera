module "vpc" {
  source = "./code/Project1/modules/vpc"
  cidr_block =var.cidr_block
  pubsub_cidr = var.pubsub_cidr
  privsub_cidr = var.privsub_cidr
  az = var.az
  env = var.env
  
}

module "ec2" {
  source = "./code/Project1/modules/ec2"
  #sub_id = var.sub_id
  sub_id = module.vpc.pub_sub_id
  sg_inst = module.vpc.pub_sg_ids
  env = var.env
}

