variable "aws_region" {
  description = "Región de la infra base."
  type        = string
  default     = "eu-west-1"
}

variable "identificador_alumno" {
  description = "Tu identificador, el mismo de tu usuario IAM sin el prefijo ucm-."
  type        = string
}

variable "imagen_tag" {
  description = "Tag de la imagen en ECR. La publica el profesor."
  type        = string
  default     = "latest"
}

variable "bucket_datos" {
  description = "Bucket ucm-* de los CSV. Lo crea este Terraform, junto con las tablas de Glue."
  type        = string
}

variable "correo_aviso" {
  description = "Correo que recibe el aviso cuando una tarea arranca o se para. SNS pide confirmar la suscripción."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.correo_aviso))
    error_message = "Indica un correo válido. Sin él, Terraform no puede crear la suscripción."
  }
}

variable "numero_tareas" {
  description = "Tareas Fargate del servicio."
  type        = number
  default     = 1

  validation {
    condition     = var.numero_tareas == 1
    error_message = "1 tarea: el taller comparte subredes y presupuesto."
  }
}
