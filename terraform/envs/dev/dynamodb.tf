resource "aws_dynamodb_table" "analysis_results" {
  name         = "analysis_results"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_hash"

  attribute {
    name = "file_hash"
    type = "S"
  }

  tags = {
    Name        = "analysis_results"
    Environment = "production"
  }
}
