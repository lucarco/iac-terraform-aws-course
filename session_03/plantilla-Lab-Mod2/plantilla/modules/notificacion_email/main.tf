resource "aws_sns_topic" "this" {
  name = var.nombre_topic
}

resource "aws_sns_topic_subscription" "correo" {
  for_each = toset(var.correos)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}
