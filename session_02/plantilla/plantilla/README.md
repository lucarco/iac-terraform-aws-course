# Laboratorio 1

Objetivo: desplegar un bucket S3 y practicar el flujo `init` → `plan` → `apply` → `destroy`.

## Qué hay ya

| Fichero | Estado |
|---|---|
| `versions.tf` | Listo (Terraform + provider AWS) |
| `main.tf` | Punto de partida del proyecto |
| `variables.tf` | `identificador_alumno` y `nombre_proyecto` |

Trabaja en esta carpeta.

## Ejercicio 1 — `terraform init`

```bash
terraform init
```

Aparece la carpeta `.terraform`. Ahí queda el provider de AWS que Terraform acaba de descargar: el intérprete que usará después para traducir lo que hay en el proyecto a llamadas contra AWS.

No subas esa carpeta a Git. Ya está en `.gitignore`.

## Ejercicio 2 — `plan` sin cambiar nada

Sin modificar ningún fichero:

```bash
terraform plan
```

El resumen tiene que ser `0 to add, 0 to change, 0 to destroy`.

## Ejercicio 3 — Provider de AWS

Crea `provider.tf` e indica la región:

```hcl
provider "aws" {
  region = "eu-west-1"
}
```

Documentación: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs>

Vuelve a lanzar `terraform plan`. Sigue en `0 to add, 0 to change, 0 to destroy`: el provider configura la conexión con AWS y no crea recursos.

## Ejercicio 4 — Bucket S3

En `main.tf`, declara un bucket con el recurso `aws_s3_bucket`.

Documentación: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket>

Vuelve a lanzar `terraform plan` y comprueba que Terraform quiere crear el bucket.

## Ejercicio 5 — Variables y locals

En `variables.tf`, asigna estos valores por defecto:

| Variable | Valor |
|---|---|
| `identificador_alumno` | tu nombre, en minúsculas y sin espacios |
| `nombre_proyecto` | `microcredencial_ucm` |

El nombre de un bucket solo admite minúsculas, números y guiones, y tiene que ser único en todo S3. `microcredencial_ucm` lleva un guion bajo: cámbialo en un `local` y combina las dos variables. Usa ese `local` en el argumento `bucket` del recurso.

Cuando el plan cuadre:

```bash
terraform plan
terraform apply
```

Al terminar, destruye el bucket para no dejarlo creado:

```bash
terraform destroy
```
