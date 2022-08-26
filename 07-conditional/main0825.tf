provider "aws" {
  region = "ap-northeast-2"
}


/*
 * Conditional Expression
 * Condtion ? If_True : If_False
 */
variable "is_john" {
  type = bool
  default = true
}

locals {
  message = var.is_john ? "Hello John!" : "Hello!" #is_john True이면 Hello John 틀리면 Hello 
                                            
}
                                                # # terraform apply -var="is_john=false"
output "message" {
  value = local.message
}


/*
 * Count Trick for Conditional Resource
 */
variable "internet_gateway_enabled" {
  type = bool
  default = true
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "this" {
  count = var.internet_gateway_enabled ? 1 : 0 # true 이면 1 internetgateway 생성 False면 0 생성 안함
                                                #terraform apply -var="internet_gateway_enabled=false" 삭제

  vpc_id = aws_vpc.this.id
}
