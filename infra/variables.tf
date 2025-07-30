variable "bucket_name" {
  description = "Nom du bucket S3"
  type        = string
  default     = "fil-rouge-samad-bucket-v2-20250122"
}

variable "dynamodb_table_name" {
  description = "Nom de la table DynamoDB"
  type        = string
  default     = "TasksTable-v2"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}