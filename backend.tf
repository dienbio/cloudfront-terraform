// IF YOU WANT YOU USE REMOTE BACKEND UNCOMMENT THOSE

##  state locking and consistency checking via Dynamo DB
# resource "aws_dynamodb_table" "tflocktablefprterragrunt" {
#   name = "exam_lock_id"
#   hash_key = "LockID"
#   read_capacity = 5
#   write_capacity = 5
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

## Store state file
# resource "aws_s3_bucket" "terraform-s3-for-terragrunt" {
#   bucket = "exam-state"
#   versioning {
#     enabled = true
# }

# lifecycle {
#   prevent_destroy = true
# }

# tags = {
#   Name = "exam-state"
#   }
# }