# 테라폼 리소스 강제 교체
# terraform init
# taint         Mark a resource instance as not fully functional
#               리소스 인스턴스를 완전히 작동하지 않는 것으로 표시
# terraform state list
# module.route_table__private.aws_route_table.this
# module.route_table__private.aws_route_table_association.subnets[0]
# module.route_table__private.aws_route_table_association.subnets[1]
# module.route_table__public.aws_route.ipv4["0.0.0.0/0"]
# module.route_table__public.aws_route_table.this
# module.route_table__public.aws_route_table_association.subnets[0]
# module.route_table__public.aws_route_table_association.subnets[1]
# module.subnet_group__private.aws_subnet.this["fastcampus-private-001/az1"]
# module.subnet_group__private.aws_subnet.this["fastcampus-private-002/az2"]
# module.subnet_group__public.aws_subnet.this["fastcampus-public-001/az1"]
# module.subnet_group__public.aws_subnet.this["fastcampus-public-002/az2"]
# module.vpc.data.aws_region.current
# module.vpc.aws_internet_gateway.this[0] #인터넷 게이트 웨이 장애라고 가정
# module.vpc.aws_vpc.this
#------------------------------------------------------------------------
#terraform taint "module.vpc.aws_internet_gateway.this[0]"
# Resource instance module.vpc.aws_internet_gateway.this[0] has been marked as tainted.

#  # module.route_table__public.aws_route.ipv4["0.0.0.0/0"] will be updated in-place
#   ~ resource "aws_route" "ipv4" {
#       ~ gateway_id             = "igw-0b19324be5b2d7d4a" -> (known after apply)  # 라우팅 규칙이 인터넷 게이트웨이로 보내는 규칙 
#         id                     = "r-rtb-0a863b6cae0e8faf11080289494"       # 의존성 관련된 것들도 변경
#         # (4 unchanged attributes hidden)
#     }
 # module.vpc.aws_internet_gateway.this[0] is tainted, so must be replaced

# -/+ resource "aws_internet_gateway" "this" {   #인터넷 게이트 웨이 변경 시도 
#       ~ arn      = "arn:aws:ec2:ap-northeast-2:028390521656:internet-gateway/igw-0b19324be5b2d7d4a" -> (known after apply)
#       ~ id       = "igw-0b19324be5b2d7d4a" -> (known after apply)
#       ~ owner_id = "028390521656" -> (known after apply)
#         tags     = {
#             "Name"                          = "fastcampus"
#             "Owner"                         = "sol"
#             "Project"                       = "Network"
#             "module.terraform.io/full-name" = "terraform-aws-network/vpc"
#             "module.terraform.io/instance"  = "fastcampus"
#             "module.terraform.io/name"      = "vpc"
#             "module.terraform.io/package"   = "terraform-aws-network"
#             "module.terraform.io/version"   = "0.24.0"
#         }
#         # (2 unchanged attributes hidden)
#     }

# 다른 리소스도 건드리는것 같아서 취소 하고 싶을 떄는 untaint
# terraform untaint "module.vpc.aws_internet_gateway.this[0]"
# Resource instance module.vpc.aws_internet_gateway.this[0] has been successfully untainted.

# terraform plan -h 옵션

# #-replace=resource   Force replacement of a particular resource instance using
#                       its resource address. If the plan would've normally
#                       produced an update or no-op action for this instance,
#                       Terraform will plan to replace it instead. You can use
#                       this option multiple times to replace more than one object.

#terraform apply -replace "module.vpc.aws_internet_gateway.this[0]"
  # module.vpc.aws_internet_gateway.this[0] will be replaced, as requested
# -/+ resource "aws_internet_gateway" "this" {
#       ~ arn      = "arn:aws:ec2:ap-northeast-2:028390521656:internet-gateway/igw-0b19324be5b2d7d4a" -> (known after apply)
#       ~ id       = "igw-0b19324be5b2d7d4a" -> (known after apply)
#       ~ owner_id = "028390521656" -> (known after apply)
#         tags     = {
#             "Name"                          = "fastcampus"
#             "Owner"                         = "sol"
#             "Project"                       = "Network"
#             "module.terraform.io/full-name" = "terraform-aws-network/vpc"
#             "module.terraform.io/instance"  = "fastcampus"
#             "module.terraform.io/name"      = "vpc"
#             "module.terraform.io/package"   = "terraform-aws-network"
#             "module.terraform.io/version"   = "0.24.0"
#         }
#         # (2 unchanged attributes hidden)
#     }


provider "aws" {
  region = "ap-northeast-2"
}

variable "vpc_name" {
  description = "sol"
  type        = string
  default     = "default"
}

locals {
  common_tags = {
    Project = "Network"
    Owner   = "posquit0"
  }
}

output "vpc_name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr" {
  description = "생성된 VPC의 CIDR 영역"
  value = module.vpc.cidr_block
}

output "subnet_groups" {
  value = {
    public  = module.subnet_group__public
    private = module.subnet_group__private
  }
}

module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name                  = var.vpc_name
  cidr_block            = "10.0.0.0/16"

  internet_gateway_enabled = true

  dns_hostnames_enabled = true
  dns_support_enabled   = true

  tags = local.common_tags
}

module "subnet_group__public" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name                    = "${module.vpc.name}-public"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = true

  subnets = {
    "${module.vpc.name}-public-001/az1" = {
      cidr_block           = "10.0.0.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-public-002/az2" = {
      cidr_block           = "10.0.1.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = local.common_tags
}

module "subnet_group__private" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name                    = "${module.vpc.name}-private"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = false

  subnets = {
    "${module.vpc.name}-private-001/az1" = {
      cidr_block           = "10.0.10.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}-private-002/az2" = {
      cidr_block           = "10.0.11.0/24"
      availability_zone_id = "apne2-az2"
    }
  }

  tags = local.common_tags
}

module "route_table__public" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-public"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__public.ids

  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    },
  ]

  tags = local.common_tags
}

module "route_table__private" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-private"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__private.ids

  ipv4_routes = []

  tags = local.common_tags
}
