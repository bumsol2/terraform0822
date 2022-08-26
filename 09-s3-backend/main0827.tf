#terraform.tfstate 는 localstate

# locatState / Remote State 
# Backend(State Storage)  리모트 상태 저장
# Local Backend #개인 작업만 가능하다.
# Remote Backend (Terraform Cloud) #simple, powerful하다  Locking? 
# 여러 작업자가 작업 => Issue! 발생 동시성 이슈 
# 동시에 2명 작업 하면 한명은 락을 걸어버려서 끝나게 된다.
# AWS S3 Backend  (with/ withdout DynamoDB) 
#consol Backend
#Kubernetes Backend
terraform {
  backend "s3" {  #s3 선언
    bucket = "fastcampus-devops-sol" #버킷 이름 글로벌 unique
    key    = "s3-backend/terraform.tfstate" #  버킷 내에 file에 대한 path
    region = "ap-northeast-2"   #버킷 리전 지정
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

/*
 * Groups
 */

resource "aws_iam_group" "developer" {
  name = "developer"
}

resource "aws_iam_group" "employee" {
  name = "employee"
}

output "groups" {
  value = [
    aws_iam_group.developer,
    aws_iam_group.employee,
  ]
}


/*
 * Users
 */

variable "users" {
  type = list(any)
}

resource "aws_iam_user" "this" {
  for_each = {
    for user in var.users :
    user.name => user
  }

  name = each.key

  tags = {
    level = each.value.level
    role  = each.value.role
  }
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user in var.users :
    user.name => user
  }

  user   = each.key
  groups = each.value.is_developer ? [aws_iam_group.developer.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]
}

locals {
  developers = [
    for user in var.users :
    user
    if user.is_developer
  ]
}

resource "aws_iam_user_policy_attachment" "developer" {
  for_each = {
    for user in local.developers :
    user.name => user
  }

  user       = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    aws_iam_user.this
  ]
}

output "developers" {
  value = local.developers
}

output "high_level_users" {
  value = [
    for user in var.users :
    user
    if user.level > 5
  ]
}

#terraform destroy  로 모든 리소스 제거 
