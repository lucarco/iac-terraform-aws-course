# Sigue el README. Los recursos de este laboratorio se declaran aquí.


# Ejercicio 1
data "aws_iam_role" "lambda" {
  name = "ucm-lambda-reloj"
}


# Ejercicio 2
# Poner un nombre propio al reloj pq lo mismo ese reloj con ese nombre ya está creado
resource "aws_sns_topic" "relojlucasarranz" {
  name = "ucm-user-updates-topic-reloj-lucasarranz"
}

# Crear un resource que me haga cosas con los correos
resource "aws_sns_topic_subscription" "correo" {
  for_each  = toset(var.correo)
    topic_arn = aws_sns_topic.relojlucasarranz.arn
    protocol  = "email"
    endpoint  = each.value
}



# Ejercicio 3
data "archive_file""reloj" {
    type = "zip"
    source_file = "${path.module}/src/reloj/lambda_function.py"
    output_path = "${path.module}/reloj.zip"
}


resource "aws_lambda_function" "reloj" {
    function_name = "ucm-user-updates-topic-reloj-lucasarranz"
    role = aws_sns_topic.relojlucasarranz.arn
    filename = archive_file.reloj.output_path
    source_code_hash = output_base64sha256
    handler = lambda_function.lambda_handler
    runtime = python3.12
    environment {
        variables = {
            SNS_TOPIC_ARN  = aws_sns_topic.relojlucasarranz.arn
            IDENTIFICADOR_ALUMNO   = var.identificador_alumno
        }
    }
    root_block_device { # disco del sistema: 20 GB cifrado
    volume_size = 20
    encrypted = true
    }
    lifecycle {
    prevent_destroy = true # Terraform rechaza un plan que la destruya
    }
    depends_on = [aws_internet_gateway.principal]
}
