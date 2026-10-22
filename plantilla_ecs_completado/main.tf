# Log group, clúster, task definition, target group, regla y servicio.
# Ya vienen escritos. El alumno rellena terraform.tfvars y aplica.

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/ucm-${replace(var.identificador_alumno, "_", "-")}"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "cluster" {
  name = "ucm-${replace(var.identificador_alumno, "_", "-")}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "ucm-${replace(var.identificador_alumno, "_", "-")}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_ejecucion.arn
  task_role_arn            = data.aws_iam_role.ecs_tarea.arn

  container_definitions = jsonencode([
    {
      name      = "fastapi"
      image     = "${data.aws_ecr_repository.fastapi.repository_url}:${var.imagen_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "API_ROOT_PATH", value = "/ucm-${replace(var.identificador_alumno, "_", "-")}" },
        { name = "S3_BUCKET", value = var.bucket_datos },
        { name = "S3_PREFIJO_RESTAURANTES", value = "restaurantes" },
        { name = "S3_PREFIJO_PRECIOS", value = "precios" },
        { name = "ATHENA_DATABASE", value = "ucm_${replace(var.identificador_alumno, "-", "_")}" },
        { name = "ATHENA_TABLE_RESTAURANTES", value = "restaurantes" },
        { name = "ATHENA_TABLE_PRECIOS", value = "precios" },
        { name = "ATHENA_WORKGROUP", value = "ucm-proyecto-final" },
        { name = "ATHENA_OUTPUT", value = "s3://${var.bucket_datos}/consultas/" },
      ]

      secrets = [
        {
          name      = "API_KEY"
          valueFrom = data.aws_ssm_parameter.api_key.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])
}

resource "aws_lb_target_group" "api" {
  name        = "ucm-${replace(var.identificador_alumno, "_", "-")}-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.base.id

  deregistration_delay = 30

  health_check {
    path                = "/ucm-${replace(var.identificador_alumno, "_", "-")}/health"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = tonumber(data.aws_ssm_parameter.prioridad.insecure_value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = [
        "/ucm-${replace(var.identificador_alumno, "_", "-")}",
        "/ucm-${replace(var.identificador_alumno, "_", "-")}/*",
      ]
    }
  }
}

resource "aws_ecs_service" "api" {
  name            = "ucm-${replace(var.identificador_alumno, "_", "-")}-api"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.numero_tareas
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.privadas.ids
    security_groups  = [data.aws_security_group.tareas.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "fastapi"
    container_port   = 8000
  }

  # El target group tiene que estar enganchado al ALB antes de crear el servicio.
  depends_on = [aws_lb_listener_rule.api]
}
