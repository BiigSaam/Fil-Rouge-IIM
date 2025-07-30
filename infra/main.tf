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

# Création du bucket S3 pour hébergement web statique
resource "aws_s3_bucket" "fil_rouge_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = "dev"
    Project     = "fil-rouge"
  }
}

# Configuration du bucket S3 pour hébergement web
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.fil_rouge_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Politique publique pour le bucket
resource "aws_s3_bucket_public_access_block" "frontend_pab" {
  bucket = aws_s3_bucket.fil_rouge_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.fil_rouge_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.frontend_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.fil_rouge_bucket.arn}/*"
      }
    ]
  })
}

# Archive automatique de la fonction Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.js"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda pour l'API
resource "aws_lambda_function" "tasks_api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "tasks-api"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.handler"
  runtime         = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.tasks_table.name
    }
  }

  tags = {
    Environment = "dev"
    Project     = "fil-rouge"
  }
}

# Rôle IAM pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "tasks-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Politique pour Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "tasks-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.tasks_table.arn
      }
    ]
  })
}

# API Gateway
resource "aws_api_gateway_rest_api" "tasks_api" {
  name        = "tasks-api"
  description = "API pour les tâches"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tasks_resource" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id   = aws_api_gateway_rest_api.tasks_api.root_resource_id
  path_part   = "tasks"
}

resource "aws_api_gateway_resource" "task_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id   = aws_api_gateway_resource.tasks_resource.id
  path_part   = "{id}"
}

# Méthodes API Gateway
# GET /tasks
resource "aws_api_gateway_method" "get_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# POST /tasks
resource "aws_api_gateway_method" "post_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# DELETE /tasks/{id}
resource "aws_api_gateway_method" "delete_task" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.task_id_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# OPTIONS pour CORS
resource "aws_api_gateway_method" "options_tasks" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.tasks_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_task_id" {
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.task_id_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Intégrations Lambda
resource "aws_api_gateway_integration" "get_tasks_integration" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.tasks_resource.id
  http_method = aws_api_gateway_method.get_tasks.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.tasks_api.invoke_arn
}

resource "aws_api_gateway_integration" "post_tasks_integration" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.tasks_resource.id
  http_method = aws_api_gateway_method.post_tasks.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.tasks_api.invoke_arn
}

resource "aws_api_gateway_integration" "delete_task_integration" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.task_id_resource.id
  http_method = aws_api_gateway_method.delete_task.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.tasks_api.invoke_arn
}

# Intégrations CORS (OPTIONS)
resource "aws_api_gateway_integration" "options_tasks_integration" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.tasks_resource.id
  http_method = aws_api_gateway_method.options_tasks.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.tasks_api.invoke_arn
}

resource "aws_api_gateway_integration" "options_task_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.task_id_resource.id
  http_method = aws_api_gateway_method.options_task_id.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.tasks_api.invoke_arn
}

# Permissions Lambda
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tasks_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/*"
}

# Déploiement API
resource "aws_api_gateway_deployment" "tasks_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_tasks_integration,
    aws_api_gateway_integration.post_tasks_integration,
    aws_api_gateway_integration.delete_task_integration,
    aws_api_gateway_integration.options_tasks_integration,
    aws_api_gateway_integration.options_task_id_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.tasks_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tasks_resource.id,
      aws_api_gateway_resource.task_id_resource.id,
      aws_api_gateway_method.get_tasks.id,
      aws_api_gateway_method.post_tasks.id,
      aws_api_gateway_method.delete_task.id,
      aws_api_gateway_method.options_tasks.id,
      aws_api_gateway_method.options_task_id.id,
      aws_api_gateway_integration.get_tasks_integration.id,
      aws_api_gateway_integration.post_tasks_integration.id,
      aws_api_gateway_integration.delete_task_integration.id,
      aws_api_gateway_integration.options_tasks_integration.id,
      aws_api_gateway_integration.options_task_id_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage API Gateway
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.tasks_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  stage_name    = "prod"

  tags = {
    Environment = "dev"
    Project     = "fil-rouge"
  }
}

# Output des URLs importantes
output "s3_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.frontend_website.website_endpoint}"
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.tasks_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}
