# dns_alb y url_api ya están: con ellas se entra a la API.
# El bucket, la base de Glue y la función de aviso siguen comentados.

output "dns_alb" {
  description = "DNS del ALB compartido."
  value       = data.aws_lb.base.dns_name
}

output "url_api" {
  description = "URL de tu API, con el prefijo /ucm-<id>/."
  value       = "http://${data.aws_lb.base.dns_name}/ucm-${replace(var.identificador_alumno, "_", "-")}/"
}

# TODO: Descomentar y completar
# output "bucket_datos" {
#   description = "Nombre del bucket de CSV."
#   value       = "" # TODO: Completar
# }

# TODO: Descomentar y completar
# output "base_athena" {
#   description = "Nombre de la base de Glue."
#   value       = "" # TODO: Completar
# }

# TODO: Descomentar y completar
# output "funcion_aviso" {
#   description = "Nombre de la función Lambda del aviso."
#   value       = "" # TODO: Completar
# }
