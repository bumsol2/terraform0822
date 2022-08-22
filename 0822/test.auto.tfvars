#vpc_name = "so2" 

#terraform.tfvars파일(있는 경우) . 1순위
#terraform.tfvars.json파일(있는 경우) . 2순위
#*.auto.tfvars파일 이름의 사전 순서 로 처리된 모든 *.auto.tfvars.json파일. 3순위
# .tfvars => tfvars.jon => *.auto.tfvars 요 순서 

#제공된 순서대로 명령줄의 모든 -var및 옵션. -var-file(여기에는 Terraform Cloud 작업 공간에서 설정한 변수가 포함됩니다.)
# terraform apply -var="vpn_name=sol3"  이렇게도 가능하다.
