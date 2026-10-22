# Aviso por correo cuando una tarea ECS del clúster pasa a RUNNING o STOPPED.
resource "aws_cloudwatch_event_rule" "aviso" {
  name        = "ucm-${replace(var.identificador_alumno, "_", "-")}-aviso"
  description = "Tareas que pasan a RUNNING o STOPPED."

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      clusterArn = [aws_ecs_cluster.cluster.arn]
      lastStatus = ["RUNNING", "STOPPED"]
    }
  })
}

resource "aws_sns_topic" "aviso" {
  name = "ucm-${replace(var.identificador_alumno, "_", "-")}-aviso"
}


resource "aws_sns_topic_subscription" "aviso" {
  topic_arn = aws_sns_topic.aviso.arn
  protocol  = "email"
  endpoint  = var.correo_aviso
}

resource "aws_cloudwatch_log_group" "aviso" {
  name              = "/aws/lambda/ucm-${replace(var.identificador_alumno, "_", "-")}-aviso"
  retention_in_days = 7
}

data "archive_file" "aviso" {
  type        = "zip"
  source_file = "${path.module}/src/aviso/lambda_function.py"
  output_path = "${path.module}/aviso.zip"
}


resource "aws_lambda_function" "aviso" {
  function_name    = "ucm-${replace(var.identificador_alumno, "_", "-")}-aviso"
  role             = data.aws_iam_role.lambda.arn
  filename         = data.archive_file.aviso.output_path
  source_code_hash = data.archive_file.aviso.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      IDENTIFICADOR_ALUMNO = var.identificador_alumno
      SNS_TOPIC_ARN        = aws_sns_topic.aviso.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.aviso]
}

resource "aws_cloudwatch_event_target" "aviso" {
  rule = aws_cloudwatch_event_rule.aviso.name
  arn  = aws_lambda_function.aviso.arn

  depends_on = [aws_lambda_permission.aviso]
}

resource "aws_lambda_permission" "aviso" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.aviso.function_name
  source_arn    = aws_cloudwatch_event_rule.aviso.arn
}
