resource "aws_apigatewayv2_api" "todo_terraform" {
  name        = "TerraformTodoAPI"
  description = "Terraform Serverless Application Example"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = [
      "Content-Type",
      "X-Amz-Date",
      "Authorization",
      "X-Api-Key",
      "X-Amz-Security-Token",
      "X-Amz-User-Agent"
    ]
    allow_methods = [
      "OPTIONS",
      "POST",
      "GET",
      "PUT",
      "DELETE"
    ]
    allow_origins = [
      "*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "HttpApiLogGroup" {
  name = "/aws/http-api/todo-terraform-dev"
}
// Create Todo
resource "aws_lambda_permission" "CreateTodoLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo-terraform-createTodo.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.todo_terraform.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationCreateTodo" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  integration_type = "AWS_PROXY"
  integration_uri           = aws_lambda_function.todo-terraform-createTodo.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRoutePostTodo" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  route_key = "POST /todo"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationCreateTodo.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationCreateTodo]
}

// Get all Todo
resource "aws_lambda_permission" "GetTodosLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo-terraform-getTodos.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.todo_terraform.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationGetTodos" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  integration_type = "AWS_PROXY"
  integration_uri           = aws_lambda_function.todo-terraform-getTodos.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRouteGetTodo" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  route_key = "GET /todo"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationGetTodos.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationGetTodos]
}

// Get by ID
resource "aws_lambda_permission" "GetTodoByIdLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo-terraform-getTodoById.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.todo_terraform.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationGetTodoById" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  integration_type = "AWS_PROXY"
  integration_uri           = aws_lambda_function.todo-terraform-getTodoById.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRouteGetTodoIdVar" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  route_key = "GET /todo/{id}"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationGetTodoById.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationGetTodoById]
}

// Update by ID
resource "aws_lambda_permission" "UpdateTodoLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo-terraform-updateTodo.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.todo_terraform.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationUpdateTodo" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  integration_type = "AWS_PROXY"
  integration_uri           = aws_lambda_function.todo-terraform-updateTodo.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRoutePutTodoIdVar" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  route_key = "PUT /todo/{id}"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationUpdateTodo.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationUpdateTodo]
}

// Delete by ID
resource "aws_lambda_permission" "DeleteTodoLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo-terraform-deleteTodo.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.todo_terraform.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationDeleteTodo" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  integration_type = "AWS_PROXY"
  integration_uri           = aws_lambda_function.todo-terraform-deleteTodo.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRouteDeleteTodoIdVar" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  route_key = "DELETE /todo/{id}"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationDeleteTodo.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationDeleteTodo]
}

resource "aws_apigatewayv2_stage" "HttpApiStage" {
  api_id = aws_apigatewayv2_api.todo_terraform.id
  name = "dev"
  auto_deploy = true
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit = 10
    throttling_rate_limit = 10
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.HttpApiLogGroup.arn
    format = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\", \"errorIntegration\":\"$context.integrationErrorMessage\"}"
  }
  depends_on = [aws_cloudwatch_log_group.HttpApiLogGroup]
}
