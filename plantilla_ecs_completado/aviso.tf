# Aviso de arranque y parada. No enciende ni apaga el servicio: solo manda el correo.
# La regla ya está. El resto de recursos los creareis vosotros.

# El clúster ya está en main.tf. Esta regla filtra por su ARN.
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
