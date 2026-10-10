# Laboratorio 2

Objetivo: una Lambda de Python que, cada 10 minutos, publica la hora en un topic SNS. El topic y las suscripciones acaban dentro de un módulo que creas tú.

El rol de la Lambda ya existe. No tienes permiso para crear roles de IAM. El nombre es `ucm-lambda-reloj`.

Trabaja en esta carpeta. No hay carpeta `modules/`: la creas en el ejercicio 8.

## Antes de empezar

Todo lo que crees tiene que llevar estas etiquetas. Van en el provider, en `default_tags`, y no en cada recurso: el provider se las pone a todo lo que se pueda etiquetar. Si una clave coincide con un `tags` del recurso, gana la del recurso.

`Alumno` toma `var.identificador_alumno`. Sin valor en esa variable, el `plan` no arranca.

```hcl
provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      ...
    }
  }
}
```

Ese bloque ya está en `provider.tf`.

## Ejercicio 1 — Rol de la Lambda

En `main.tf`, lee el rol con el data source `aws_iam_role`. 



El argumento `name` = `ucm-lambda-reloj`

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role)

## Ejercicio 2 — Topic y suscripciones en el raíz

Declara el topic en el raíz, todavía sin módulo. El recurso se llama `aws_sns_topic.reloj`.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)

Argumento necesario: `name`.

Después, una suscripción por correo. El recurso se llama `aws_sns_topic_subscription.correo`. La variable `correos` es una lista, y `for_each` no acepta listas: pásala por `toset()`. Si se repite un correo, el set lo deja una sola vez.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)


| Argumento   | Valor         |
| ----------- | ------------- |
| `topic_arn` | ARN del topic |
| `protocol`  | `"email"`     |
| `endpoint`  | `each.value`  |


## Ejercicio 3 — Empaquetar el código

El código está en `src/reloj/lambda_function.py`. No lo cambies. Empaquétalo con el data source `archive_file`: `type = "zip"`, `source_file` apuntando a ese fichero y `output_path` a `reloj.zip`.

Documentación: [https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file)

El provider `archive` , necesario en este paso, ya está en `versions.tf`. 

## Ejercicio 4 — Lambda

Crea `aws_lambda_function.reloj`.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)

Argumentos necesarios:


| Argumento          | Valor                                                                                   |
| ------------------ | --------------------------------------------------------------------------------------- |
| `function_name`    | El nombre `ucm-...-reloj`                                                               |
| `role`             | ARN del data source. No es el nombre del rol                                            |
| `filename`         | Ruta del zip (`output_path` del data source)                                            |
| `source_code_hash` | `output_base64sha256` del data source. Sin esto, un cambio en el Python no se despliega |
| `handler`          | `lambda_function.lambda_handler`                                                        |
| `runtime`          | `python3.12`                                                                            |
| `environment`      | Dos variables: `SNS_TOPIC_ARN` (ARN del topic) e `IDENTIFICADOR_ALUMNO`                 |


El Python lee esas dos variables. Si falta `SNS_TOPIC_ARN`, la ejecución falla y el error queda en CloudWatch. El asunto del correo lleva tu identificador, para poder filtrar el buzón. El cuerpo es `Soy tu reloj de Amazon, son las {hora UTC}`.

EventBridge no envía el topic. La función lo toma del entorno.

## Ejercicio 5 — Regla cada 10 minutos

Crea `aws_cloudwatch_event_rule.reloj` con `schedule_expression = "rate(10 minutes)"` y el mismo nombre AWS.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)

Conecta la regla a la Lambda con `aws_cloudwatch_event_target.reloj`.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)


| Argumento | Valor              |
| --------- | ------------------ |
| `rule`    | Nombre de la regla |
| `arn`     | ARN de la Lambda   |


No hace falta `input`. El topic ya está en el entorno de la función.

## Ejercicio 6 — Permiso para que EventBridge invoque

Sin este recurso la regla existe y la Lambda no se ejecuta.

Documentación: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)


| Argumento       | Valor                                                              |
| --------------- | ------------------------------------------------------------------ |
| `statement_id`  | Un identificador fijo, por ejemplo `AllowExecutionFromEventBridge` |
| `action`        | `lambda:InvokeFunction`                                            |
| `function_name` | Nombre de la función                                               |
| `principal`     | `events.amazonaws.com`                                             |
| `source_arn`    | ARN de la regla                                                    |


## Ejercicio 7 — Aplicar y probar

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

AWS envía un correo de confirmación desde `no-reply@sns.amazonaws.com` a cada dirección, también a la del profesor. Hasta que se pulsa el enlace, la suscripción queda en `PendingConfirmation` y el mensaje no llega. Revisa la carpeta de spam.

Para no esperar 10 minutos:

```bash
aws lambda invoke \
  --function-name ucm-<identificador>-reloj \
  --region eu-west-1 \
  respuesta.json

cat respuesta.json
```

Sustituye el nombre por el tuyo (`_` del identificador pasado a `-`).

No lances `destroy` todavía: el ejercicio siguiente mueve recursos que ya están en el estado.

## Ejercicio 8 — Módulo y `moved`

Crea `modules/notificacion_email/` con esta estructura. El hijo no lleva bloque `provider`: si lo declaras, el módulo pierde `count`, `for_each` y `depends_on`.


| Fichero        | Contenido                                              |
| -------------- | ------------------------------------------------------ |
| `versions.tf`  | `required_providers` de AWS, sin bloque `provider`     |
| `variables.tf` | Entradas con `type` y `description`                    |
| `main.tf`      | Topic y suscripciones                                  |
| `outputs.tf`   | Lo que el raíz necesita. Como mínimo, el ARN del topic |
| `README.md`    | Para qué sirve, qué entra y qué sale                   |


Pasa al módulo el topic y las suscripciones. Dentro, el topic se llama `aws_sns_topic.this` (en un módulo el nombre es neutro: quién llama elige el papel). La suscripción sigue llamándose `aws_sns_topic_subscription.correo`, con el mismo `for_each`.

En el raíz, sustituye esos dos recursos por una llamada:

```hcl
module "notificacion" {
  source = "./modules/notificacion_email"
}
```

Los argumentos del bloque son las variables del módulo: el nombre del topic y la lista de correos. La Lambda pasa a leer el ARN desde el output del módulo.

Si solo mueves el código, Terraform ve recursos que desaparecen y otros nuevos: destruye el topic y hay que confirmar los correos otra vez. Los bloques `moved` le dicen que es el mismo objeto.

Documentación: [https://developer.hashicorp.com/terraform/language/modules/develop/refactoring](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)

```hcl
moved {
  from = aws_sns_topic.reloj
  to   = module.notificacion.aws_sns_topic.this
}

moved {
  from = aws_sns_topic_subscription.correo
  to   = module.notificacion.aws_sns_topic_subscription.correo
}
```

Tras cambiar el código:

```bash
terraform init
terraform plan
```

El plan tiene que quedar en `0 to add, 0 to change, 0 to destroy`, con líneas `has moved to`. Entonces sí:

```bash
terraform apply
```

Los bloques `moved` se quedan mientras alguien pueda tener un estado con la dirección antigua.

## Cierre

```bash
terraform fmt -check -recursive
terraform validate
terraform destroy
```

`destroy` es parte del laboratorio. Cada función olvidada sigue enviando un correo cada 10 minutos.

El lock file (`.terraform.lock.hcl`) se versiona. En el laboratorio 1 se ignoró para simplificar.