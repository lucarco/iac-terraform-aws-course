output "topic_arn" {
  description = "ARN del topic SNS de notificación."
  value       = aws_sns_topic.this.arn
}
