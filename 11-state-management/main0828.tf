#terraform state
# Subcommands:
#    중요 list                List resources in the state 
#     중요 mv                  Move an item in the state
#    remote state시 유용하다 pull                Pull current state and output to stdout
#   remote state시 유용하다 위험  push                Update remote state from a local state file
#     replace-provider    Replace provider in the state
#   중요  rm                  Remove instances from the state
#     show                Show a resource in the state

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bumsol2"

    workspaces {
      name = "tf-cloud-backend"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

/*
 * Groups
 */
# resource "aws_iam_group" "developer" {
#   name = "developer"
# }

# resource "aws_iam_group" "employee" {
#   name = "employee"
# }

resource "aws_iam_group" "this" {
  for_each = toset(["developer", "employee"]) #  developer, employee
    #terraform state mv 'aws_iam_group.developer' 'aws_iam_group.this["developer"]'

  name = each.key
}

output "groups" {
  value = aws_iam_group.this
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
  groups = each.value.is_developer ? [aws_iam_group.this["developer"].name, aws_iam_group.this["employee"].name] : [aws_iam_group.this["employee"].name]
}
#  groups = each.value.is_developer ? [aws_iam_group.developer.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]
locals {
  developers = [
    for user in var.users :
    user
    if user.is_developer
  ]
}
# terraform state rm 'aws_iam_user_policy_attachement.developer["alice"]' 
# terraform state rm 'aws_iam_user_policy_attachement.developer["tony"]'
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
# terraform state pull > a.tfstate 이렇게 저장가능
