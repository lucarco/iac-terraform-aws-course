# Datos de salida para acceder a la API y localizar los recursos desplegados.

# DNS público del ALB compartido.
output "dns_alb" {
  description = "DNS del ALB compartido."
  value       = data.aws_lb.base.dns_name
}

output "url_api" {
  description = "URL de tu API, con el prefijo /ucm-<id>/."
  value       = "http://${data.aws_lb.base.dns_name}/ucm-${replace(var.identificador_alumno, "_", "-")}/"
}

output "bucket_datos" {
  description = "Nombre del bucket de CSV."
  value       = aws_s3_bucket.datos.bucket
}

output "base_athena" {
  description = "Nombre de la base de Glue."
  value       = aws_glue_catalog_database.menus.name
}

output "funcion_aviso" {
  description = "Nombre de la función Lambda del aviso."
  value       = aws_lambda_function.aviso.function_name
}
