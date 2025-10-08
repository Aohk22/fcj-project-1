resource "aws_dynamodb_table" "analysis_results" {
  name           = "analysis_results"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "file_hash"
  range_key      = "report_type"

  attribute {
    name = "file_hash"
    type = "S"
  }

  attribute {
    name = "report_type"
    type = "S"
  }

  tags = {
    Name        = "analysis_results_table"
    Environment = "production"
  }
}
