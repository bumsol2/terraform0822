provider "aws" {
  region = "ap-northeast-2"
}

/*
 * No count / for_each
 */
resource "aws_iam_user" "user_1" {  
  name = "user-1"
}

resource "aws_iam_user" "user_2" {  
  name = "user-2"
}

resource "aws_iam_user" "user_3" {
  name = "user-3"
}

output "user_arns" {
  value = [
    aws_iam_user.user_1.arn,
    aws_iam_user.user_2.arn,
    aws_iam_user.user_3.arn,
  ]
}

#######IAM유저 3명 생성#####
### count 와 for_each로 대량 생성 가능하다

/*
 * count  resouce /data/ module 가능하다.
 */

resource "aws_iam_user" "count" {
  count = 10   #속성을 meta-argument 라고 한다

  name = "count-user-${count.index}" #0~9 해서 10개 
}

output "count_user_arns" {
  value = aws_iam_user.count.*.arn
}


/*
 * for_each
 */

 # count의 문제점 떄문에 만들어진 기능
# set /map set은 List= Unique element set으로 형변환 해야된다. map은 ={key:value 형식}  

# set 은 집합자료형 인덱싱할려면 튜플이나 리스트로 형변환해야한다.
# 중복허용 X, 순서가 없다.
resource "aws_iam_user" "for_each_set" {
  for_each = toset([    #toset 은 set,map 지원
    "for-each-set-user-1",
    "for-each-set-user-2",
    "for-each-set-user-3",
  ])

  name = each.key
}



output "for_each_set_user_arns" {
  value = values(aws_iam_user.for_each_set).*.arn  
}      

resource "aws_iam_user" "for_each_map" {  #키 값은 string이어야 한다. 
  for_each = { 
    alice = {          #엘리스 사용자
      level = "low"      #태그 level 
      manager = "posquit0"  #태그 manager 확인
    }
    bob = {
      level = "mid"
      manager = "posquit0"
    }
    john = {
      level = "high"
      manager = "steve"
    }
  }

  name = each.key

  tags = each.value
}

output "for_each_map_user_arns" {
  value = values(aws_iam_user.for_each_map).*.arn
}

#terraform state list  
#count는 리스트로 관리 주의점 중간의 유저가 퇴사를 했다. 그래서 삭제 해야한다.
# 쉬프트 된다.
# for each는 키 벨류
# aws_iam_user.count[0]
# aws_iam_user.count[1]
# aws_iam_user.count[2]
# aws_iam_user.count[3]
# aws_iam_user.count[4]
# aws_iam_user.count[5]
# aws_iam_user.count[6]
# aws_iam_user.count[7]
# aws_iam_user.count[8]
# aws_iam_user.count[9]
# aws_iam_user.for_each_map["alice"]
# aws_iam_user.for_each_map["bob"]  #bob이 퇴사가 됬다. 하면 변경 사항이 없다.
# aws_iam_user.for_each_map["john"]
# aws_iam_user.for_each_set["for-each-set-user-1"]
# aws_iam_user.for_each_set["for-each-set-user-2"]
# aws_iam_user.for_each_set["for-each-set-user-3"]
# aws_iam_user.user_1
# aws_iam_user.user_2
# aws_iam_user.user_3


