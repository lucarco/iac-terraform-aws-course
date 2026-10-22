# Sigue el README. Los recursos de este laboratorio se declaran aquí.


# Ejercicio 1
# lee el rol con aws_im_role
data "aws_iam_role" "lambda" {
  name = "ucm-lambda-reloj"
}




/*
# Ejercicio 2 (recursos raíz anteriores; se conservan como referencia)
# Poner un nombre propio al reloj pq lo mismo ese reloj con ese nombre ya está creado
resource "aws_sns_topic" "relojlucasarranz" {
  name = "ucm-user-updates-topic-reloj-lucasarranz"
}

# Crear un resource que me haga cosas con los correos
resource "aws_sns_topic_subscription" "correo" {
  for_each  = toset(var.correo) # toset() cambia de list() a set() para que no haya duplicados
  topic_arn = aws_sns_topic.relojlucasarranz.arn
  protocol  = "email"
  endpoint  = each.value
}
*/


# Elegir entre ej.2 o ej.8
# Para el ej.8 cuando se crea módulo:
# ==================================
module "notificacion" {
  source = "./modules/notificacion_email"

  nombre_topic = "ucm-user-updates-topic-reloj-lucasarranz"
  correos      = var.correo
}

moved {
  from = aws_sns_topic.relojlucasarranz
  to   = module.notificacion.aws_sns_topic.this
}

moved {
  from = aws_sns_topic_subscription.correo
  to   = module.notificacion.aws_sns_topic_subscription.correo
}

# ==================================
# Ejercicio 3
data "archive_file" "reloj" {
  type        = "zip"
  source_file = "${path.module}/src/reloj/lambda_function.py"
  output_path = "${path.module}/reloj.zip"
}

# Ejercicio 4
resource "aws_lambda_function" "reloj" {
  function_name    = "${var.identificador_alumno}-reloj"
  role             = data.aws_iam_role.lambda.arn
  filename         = data.archive_file.reloj.output_path
  source_code_hash = data.archive_file.reloj.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"

  environment {
    variables = {
      # Para el ej. 4 que está aquí en el main()
      # SNS_TOPIC_ARN        = aws_sns_topic.relojlucasarranz.arn
      # Para el ej.8 cuando se crea un módulo
      SNS_TOPIC_ARN = module.notificacion.topic_arn
      # Para ambos
      IDENTIFICADOR_ALUMNO = var.identificador_alumno
    }
  }
}


# Ejercicio 5
# Define la programación cada 10 mins
resource "aws_cloudwatch_event_rule" "reloj" {
  name                = "${var.identificador_alumno}-reloj"
  description         = "Ejecuta la Lambda del reloj cada 10 minutos"
  schedule_expression = "rate(10 minutes)"
}


# Conecta la regla con la Lambda
resource "aws_cloudwatch_event_target" "reloj" {
  rule      = aws_cloudwatch_event_rule.reloj.name # nombre de la regla de EnventBridge
  target_id = "reloj-target"                       # id del target
  arn       = aws_lambda_function.reloj.arn        # ARN de lambda que vamos a usar
}

# Ejercicio 6
# da permiso a EventBridge para invocar la Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"         # el id del resource
  action        = "lambda:InvokeFunction"                 # la acción a hacer
  function_name = aws_lambda_function.reloj.function_name # nombre de la función
  principal     = "events.amazonaws.com"                  # a donde va
  source_arn    = aws_cloudwatch_event_rule.reloj.arn     # arn del evento
}

