# Módulo de notificación por email

Este módulo crea un topic SNS y sus suscripciones por correo para enviar mensajes del reloj.

## Entradas

- `nombre_topic`: nombre del topic SNS.
- `correos`: lista de direcciones de correo que reciben notificaciones.

## Salidas

- `topic_arn`: ARN del topic SNS creado.

## Uso

```hcl
module "notificacion" {
  source = "./modules/notificacion_email"

  nombre_topic = "ucm-user-updates-topic-reloj-${var.identificador_alumno}"
  correos      = var.correo
}
```
