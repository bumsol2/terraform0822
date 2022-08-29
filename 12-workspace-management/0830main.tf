# terraform workspace -h
# Usage: terraform [global options] workspace

#   new, list, show, select and delete Terraform workspaces.

# Subcommands:
#     delete    Delete a workspace
#     list      List Workspaces
#     new       Create a new workspace
#     select    Select a workspace
#     show      Show the name of the current workspace
# terraform workspace list
# * default
#  terraform workspace show
#  default
# terraform workspace new prod
# Created and switched to workspace "prod"!

# You're now on a new, empty workspace. Workspaces isolate their state,
# so if you run "terraform plan" Terraform will not see any existing state
# for this configuration.

# terraform workspace list
#   default
# * prod  

# terraform workspace select default

# Switched to workspace "default".

# terraform workspace delete prod

# Deleted workspace "prod"!

# terraform workspace new dev

# Created and switched to workspace "dev"!
# You're now on a new, empty workspace. Workspaces isolate their state,
# so if you run "terraform plan" Terraform will not see any existing state
# for this configuration.

# terraform workspace new staging

# Created and switched to workspace "staging"!
# You're now on a new, empty workspace. Workspaces isolate their state,
# so if you run "terraform plan" Terraform will not see any existing state
# for this configuration.

# terraform workspace new prod

# Created and switched to workspace "prod"!
# You're now on a new, empty workspace. Workspaces isolate their state,
# so if you run "terraform plan" Terraform will not see any existing state
# for this configuration.

# terraform workspace list
#   default
#   dev
# * prod
#   staging

# terraform workspace select dev
# Switched to workspace "dev".

# terraform apply -var-file=dev.tfvars
# dev 관련 VCP, 서브넷, 라우트,인터넷 게이트 웨이 생성 확인
# terraform apply -var-file=staging.tfvars
# staging 관련 VCP, 서브넷, 라우트,인터넷 게이트 웨이 생성 확인
# terraform apply -var-file=prod.tfvars
# prod 관련  VCP, 서브넷, 라우트,인터넷 게이트 웨이 생성 확인

# terraform workspace list 어떤 워크스페이스인지 확인하고 작업 
#   default
#   dev
# * prod
#   staging

# 주의 사항
#  workspace 
#  테라폼 클라우드 remote backend 상태 관리
#  workspace 기능이 다르게 동작!

