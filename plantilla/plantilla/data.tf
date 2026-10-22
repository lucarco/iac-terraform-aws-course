# Infra compartida. Estos data sources leen lo que ya existe.
# No crean VPC, ALB, roles ni repositorio.
# El repositorio, los roles y el parámetro de la API Key se declaran: están en el enunciado.
# La prioridad ya está: la usa la regla del listener.

data "aws_vpc" "base" {
  tags = {
    Name = "ucm-proyecto-final-vpc"
  }
}

data "aws_subnets" "privadas" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.base.id]
  }

  tags = {
    Tier = "privada"
  }
}

data "aws_security_group" "tareas" {
  name   = "ucm-proyecto-final-tareas"
  vpc_id = data.aws_vpc.base.id
}

data "aws_lb" "base" {
  name = "ucm-proyecto-final-alb"
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.base.arn
  port              = 80
}

data "aws_ssm_parameter" "prioridad" {
  name = "/ucm/proyecto-final/${var.identificador_alumno}/prioridad"
}

data "aws_ecr_repository" "fastapi" {
  name = "ucm-proyecto-final-fastapi"
}

data "aws_iam_role" "ecs_ejecucion" {
  name = "ucm-ecs-ejecucion"
}

data "aws_iam_role" "ecs_tarea" {
  name = "ucm-ecs-tarea"
}

data "aws_iam_role" "lambda" {
  name = "ucm-lambda-reloj"
}

data "aws_ssm_parameter" "api_key" {
  name            = "/ucm/proyecto-final/api-key"
  with_decryption = false
}
