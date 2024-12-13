/***
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr          = "20.0.0.0/16"
  public_sub_cidr = ["20.0.1.0/24","20.0.2.0/24"]
  private_sub_cidr = ["20.0.20.0/24"]
    availability_zone  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tags                = {
    Name = "main_vpc_001"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}


***/


# ===========================================================================
provider "aws" {
  secret_key = "ZKiYSvS9ExeQexGXlPHfjRjZJvQf/fixJzoXGzh6"
  access_key = "AKIAY5BIKONZ5PIRWJJE"
  region = "us-east-1"
  
}
module "vpc2" {
  source = "./modules/vpc2"
  
  tags = {
    Name = "myvpc02"
  }
  pubsub_cidr = ["11.0.1.0/24", "11.0.2.0/24"]
  privsub_cidr = ["11.0.3.0/24", "11.0.4.0/24"]
  availability_zone =  ["us-east-1a", "us-east-1b"]
  availability_zone_priv = ["us-east-1c"]
}

module "ELB" {
  source = "./modules/ELB"
  vpcid_from_mod= module.vpc2.vpcid
  subnetids_from_mod = module.vpc2.pubsubid
  lbsg = [ module.vpc2.public-lbsg ]
  lbname = "mylb01"
  tgname = "mytg01"
  instance_id = [ module.vpc2.inst-id ]
  
}

 /*** module "ASG" {
  
  source = "./modules/ASG"
  sgtemp = [module.vpc2.public-lbsg]
  asg-sub = module.vpc2.pubsubid
  tglb= [module.ELB.target_grp_arn]
    
  }
***/
output "dns_name1" {
  value = module.ELB.dns_name
}

output "ec2ipp" {
  value = module.vpc2.ec2ip
}

#output "public_ips" {
#  value = module.ASG.public_ips
#}