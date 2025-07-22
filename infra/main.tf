# Création de la table DynamoDB
resource "aws_dynamodb_table" "tasks_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = "fil-rouge"
  }
}

# Création du bucket S3
resource "aws_s3_bucket" "fil_rouge_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "dev"
    Project     = "fil-rouge"
  }
}
