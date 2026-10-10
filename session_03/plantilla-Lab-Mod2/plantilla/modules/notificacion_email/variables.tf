variable "nombre_topic" {
  description = "Nombre del topic SNS que recibirá las notificaciones del reloj."
  type        = string
}

variable "correos" {
  description = "Lista de direcciones de correo que recibirán el mensaje del reloj."
  type        = list(string)
}
