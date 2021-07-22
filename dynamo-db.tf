resource "aws_dynamodb_table" "TodosTable" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"
  name = var.table_name
  attribute {
    name = "id"
    type = "S"
  }
}
