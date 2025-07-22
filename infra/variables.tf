variable "bucket_name" {
  description = "Nom du bucket S3"
  type        = string
  default     = "fil-rouge-samad-bucket-20250722"
}

variable "dynamodb_table_name" {
  description = "Nom de la table DynamoDB"
  type        = string
  default     = "TasksTable"
}