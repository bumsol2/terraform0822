#테라폼 HCL 반복문(for)
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

resouce "aws_iam_group" "engineer" {
    name = "engineer"
}

output "groups" {
  value = [
    aws_iam_group.developer,   #developer그룹 생성 확인
    aws_iam_group.employee,    #employee 그룹 생성 확인
    aws_iam_group.engineer,    #engineer 그룹 생성 테스트
  ]
}


/*
 * Users
 */

variable "users" {   #변수 주입
  type = list(any)
}

resource "aws_iam_user" "this" {  
  for_each = {                   
    for user in var.users :  
    user.name => user   #user.name이 키 전체 유저 정보가 value로 들어간다.
  }

  name = each.key   #each.key 는user.name

  tags = {
    level = each.value.level
    role  = each.value.role   #each.value 는 user
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

locals {   #지역변수
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
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" #developer 인 사람들에게 관리자 권한 부여

  depends_on = [  #의존성 관리 속성
    aws_iam_user.this
  ]
}

output "developers" {
  value = local.developers
}

output "high_level_users" {
  value = [
    for user in var.users :   #전체 사용자 
    user
    if user.level > 5     #유저 5레벨 이상만 출력
  ]
}
