terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "flo"
  region  = "us-east-1"
}

resource "aws_cloudwatch_log_group" "CreateTodoLogGroup" {
  name = "/aws/lambda/todo-terraform-dev-createTodo"
}

resource "aws_cloudwatch_log_group" "GetTodosLogGroup" {
  name = "/aws/lambda/todo-terraform-dev-getTodos"
}

resource "aws_cloudwatch_log_group" "GetTodoByIdLogGroup" {
  name = "/aws/lambda/todo-terraform-dev-getTodoById"
}

resource "aws_cloudwatch_log_group" "UpdateTodoLogGroup" {
  name = "/aws/lambda/todo-terraform-dev-updateTodo"
}

resource "aws_cloudwatch_log_group" "DeleteTodoLogGroup" {
  name = "/aws/lambda/todo-terraform-dev-deleteTodo"
}

// lambdas
resource "aws_lambda_function" "todo-terraform-createTodo" {
  function_name = "todo-terraform-createTodo"
  memory_size = 128
  timeout = 6

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = var.s3_bucket
  s3_key    = "${var.sub_folder}/${var.zip_name}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "src/functions/todo/handler.createTodo"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TODO_TABLE_NAME = var.table_name
    }
  }
  depends_on = [aws_cloudwatch_log_group.CreateTodoLogGroup]
}

resource "aws_lambda_function" "todo-terraform-getTodos" {
  function_name = "todo-terraform-getTodos"
  memory_size = 128
  timeout = 6

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = var.s3_bucket
  s3_key    = "${var.sub_folder}/${var.zip_name}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "src/functions/todo/handler.getTodos"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TODO_TABLE_NAME = var.table_name
    }
  }
  depends_on = [aws_cloudwatch_log_group.GetTodosLogGroup]
}

resource "aws_lambda_function" "todo-terraform-getTodoById" {
  function_name = "todo-terraform-getTodoById"
  memory_size = 128
  timeout = 6

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = var.s3_bucket
  s3_key    = "${var.sub_folder}/${var.zip_name}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "src/functions/todo/handler.getTodoById"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TODO_TABLE_NAME = var.table_name
    }
  }
  depends_on = [aws_cloudwatch_log_group.GetTodoByIdLogGroup]
}

resource "aws_lambda_function" "todo-terraform-updateTodo" {
  function_name = "todo-terraform-updateTodo"
  memory_size = 128
  timeout = 6

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = var.s3_bucket
  s3_key    = "${var.sub_folder}/${var.zip_name}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "src/functions/todo/handler.updateTodo"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TODO_TABLE_NAME = var.table_name
    }
  }
  depends_on = [aws_cloudwatch_log_group.UpdateTodoLogGroup]
}

resource "aws_lambda_function" "todo-terraform-deleteTodo" {
  function_name = "todo-terraform-deleteTodo"
  memory_size = 128
  timeout = 6

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = var.s3_bucket
  s3_key    = "${var.sub_folder}/${var.zip_name}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "src/functions/todo/handler.deleteTodo"
  runtime = "nodejs14.x"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TODO_TABLE_NAME = var.table_name
    }
  }
  depends_on = [aws_cloudwatch_log_group.DeleteTodoLogGroup]
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_terraform_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy_terraform" {
  name = "todo-terraform-lambda_exec"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource: [
          aws_cloudwatch_log_group.CreateTodoLogGroup.arn,
          aws_cloudwatch_log_group.DeleteTodoLogGroup.arn,
          aws_cloudwatch_log_group.GetTodoByIdLogGroup.arn,
          aws_cloudwatch_log_group.GetTodosLogGroup.arn,
          aws_cloudwatch_log_group.UpdateTodoLogGroup.arn
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "logs:PutLogEvents"
        ],
        Resource: [
          aws_cloudwatch_log_group.CreateTodoLogGroup.arn,
          aws_cloudwatch_log_group.DeleteTodoLogGroup.arn,
          aws_cloudwatch_log_group.GetTodoByIdLogGroup.arn,
          aws_cloudwatch_log_group.GetTodosLogGroup.arn,
          aws_cloudwatch_log_group.UpdateTodoLogGroup.arn
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "dynamodb:DescribeTable",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource: [
          "arn:aws:dynamodb:*:*:table/${var.table_name}",
          "arn:aws:dynamodb:*:*:table/${var.table_name}/index/*"
        ]
      }
    ]
  })
}
