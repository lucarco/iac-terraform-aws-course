<style>
/* Markdown PDF (Chrome) parte un <pre> si tiene overflow distinto de visible. */
pre,
pre code,
pre.hljs,
pre.hljs code > div,
pre:not(.hljs) {
  overflow: visible !important;
  break-inside: avoid !important;
  page-break-inside: avoid !important;
}
</style>

# Configuración inicial del portátil

Esta sesión no entra en Terraform. En clase se explica qué es el cloud. Este documento deja el equipo listo para el módulo siguiente.

Vamos a instalar lo que Terraform necesita para trabajar: las extensiones del editor y la CLI. Después dejamos en el ordenador unas credenciales de AWS válidas, ligadas al usuario que se os entrega. Terraform las lee de ahí en los despliegues de las siguientes clases; no hace falta volver a pegarlas en cada laboratorio.

Al terminar, estos tres comandos tienen que responder bien:

```bash
terraform --version        # Terraform v1.15.9
aws --version              # aws-cli/2...
aws sts get-caller-identity
```

La región de la cuenta del curso es **`eu-west-1`** (Irlanda). Usad esa región en todos los pasos.

---

## 1. Extensiones en Visual Studio Code

En el marketplace hay que instalar estas **dos**. El nombre se repite; el publicador es lo que las distingue.

| Extensión | Publicador | Identificador | Para qué sirve |
| :--- | :--- | :--- | :--- |
| **Terraform** | Anton Kulikov | `4ops.terraform` | Resaltado y snippets de `.tf` y Terragrunt |
| **HashiCorp Terraform** | HashiCorp | `HashiCorp.terraform` | Autocompletado, validación y formato de los ficheros `.tf` |

Desde la interfaz: icono de extensiones, buscar `terraform`, e instalar la de **Anton Kulikov** y la de **HashiCorp**.

---

## 2. Terraform

### Versión del curso: 1.15.9

Instalad **Terraform 1.15.9** y no otra. Es la misma para todos los módulos.

- La CLI es gratuita. No hace falta cuenta de HashiCorp, clave de licencia ni suscripción de HCP Terraform (el producto de pago). Se descarga el binario y se usa.
- La línea 1.15 lleva el último parche (19 de agosto de 2026) y sigue en soporte de seguridad.
- La 1.16.4 es más nueva (23 de septiembre de 2026). No la fijamos en el curso: acaba de salir.
- Cubre la sintaxis de los laboratorios. El material pide como mínimo la 1.5, y el bloqueo de estado en S3 pide la 1.10. La 1.15 incluye ambas.

### Windows

En PowerShell. Deja `terraform.exe` en `%USERPROFILE%\bin` y añade esa carpeta al `PATH` del usuario. No hace falta administrador.

```powershell
$version = "1.15.9"

$dest = "$env:USERPROFILE\bin"

New-Item -ItemType Directory -Force -Path $dest | Out-Null

$zip = "$env:TEMP\terraform.zip"

Invoke-WebRequest `
    -Uri "https://releases.hashicorp.com/terraform/$version/terraform_${version}_windows_amd64.zip" `
    -OutFile $zip

Expand-Archive -Path $zip -DestinationPath $dest -Force

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$dest*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$dest", "User")
}

Write-Host "Terraform instalado en $dest"
Write-Host "Cierra y vuelve a abrir PowerShell y ejecuta: terraform version"
```

Para comprobar la instalación, cerrad PowerShell y abrid otra ventana. Poned:

```powershell
terraform --version
```

Si devuelve `Terraform v1.15.9`, la instalación está bien.

### Linux

Hace falta `curl` y `unzip` (`sudo apt install curl unzip` en Debian y Ubuntu). El script elige `amd64` o `arm64` según la máquina e instala el binario en `/usr/local/bin`.

```bash
VERSION=1.15.9
case "$(uname -m)" in
  x86_64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Arquitectura no contemplada: $(uname -m)" >&2; exit 1 ;;
esac

curl -fsSL -o /tmp/terraform.zip \
  "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCH}.zip"
sudo unzip -o /tmp/terraform.zip -d /usr/local/bin
sudo chmod 755 /usr/local/bin/terraform
rm -f /tmp/terraform.zip
```

El repositorio `apt` de HashiCorp instala la última versión publicada, no la 1.15.9. Por eso el curso usa el zip.

Para comprobar la instalación, cerrad la terminal y abrid otra. Poned:

```bash
terraform --version
```

Si devuelve `Terraform v1.15.9`, la instalación está bien.

### macOS, con asdf

[asdf](https://asdf-vm.com/) instala la versión exacta y la deja activa en el usuario. Si ya lo tenéis, saltad a «Plugin y versión».

Instalad asdf con Homebrew:

```bash
brew install asdf
```

En zsh (el shell por defecto de macOS), añadid los shims al `PATH`. Pegad esta línea en `~/.zshrc`:

```bash
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

Abrid una terminal nueva, o ejecutad `source ~/.zshrc`, y comprobad que el comando responde:

```bash
asdf --version
```

Plugin y versión:

```bash
asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf install terraform 1.15.9
asdf set -u terraform 1.15.9
```

Para comprobar la instalación, cerrad la terminal y abrid otra. Poned:

```bash
terraform --version
```

Si devuelve `Terraform v1.15.9`, la instalación está bien.

`asdf set -u` escribe `terraform 1.15.9` en `~/.tool-versions`. Esa versión vale en cualquier carpeta de vuestro usuario. Un `.tool-versions` dentro de un proyecto gana sobre el de casa: si en algún directorio Terraform no es la 1.15.9, mirad si hay un `.tool-versions` local.

Si `asdf plugin add` dice que el plugin ya existe, seguid con `asdf install`. Si la descarga falla por una dependencia, instalad `gpg` y `unzip` (`brew install gpg unzip`) y repetid el `install`.

---

## 3. Usuario de AWS y AWS CLI

Cada alumno tiene un usuario de IAM en la cuenta del curso, con nombre `ucm-<identificador>` (por ejemplo, `ucm-ana_garcia`). Con el usuario se entregan dos claves:

| Clave | Qué es |
| :--- | :--- |
| **Access key ID** | Identificador público de la clave. Empieza por `AKIA`. |
| **Secret access key** | Secreto. Solo se muestra una vez. Equivale a una contraseña. |

Esas claves son la identidad con la que la AWS CLI, y más adelante Terraform, llaman a la API de AWS. No las subáis a Git, no las peguéis en un chat y no las metáis en un fichero `.tf`.

Instalad **AWS CLI versión 2**. La versión 1 usa el mismo comando `aws` y se queda corta para este curso. `aws --version` tiene que empezar por `aws-cli/2`.

### Windows

El instalador de usuario no pide administrador: [AWSCLIV2-User.msi](https://awscli.amazonaws.com/AWSCLIV2-User.msi). Ejecutadlo y aceptad las opciones por defecto.

Desde PowerShell, el mismo resultado:

```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2-User.msi
```

Para comprobar la instalación, cerrad PowerShell y abrid otra ventana. Poned:

```powershell
aws --version
```

Si devuelve una línea que empieza por `aws-cli/2`, la instalación está bien.

### Linux

El script oficial instala la CLI del usuario en `~/.local` (sin `sudo`) y crea el enlace `~/.local/bin/aws`. Detecta x86_64 y ARM.

```bash
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
```

`~/.local/bin` tiene que estar en el `PATH`. En bash, línea en `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Para comprobar la instalación, cerrad la terminal y abrid otra. Poned:

```bash
aws --version
```

Si devuelve una línea que empieza por `aws-cli/2`, la instalación está bien.

Si tenéis `sudo` y preferís dejarla en `/usr/local/bin` para todos los usuarios de la máquina:

```bash
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system
```

### macOS

El mismo script que en Linux. Instala para el usuario actual:

```bash
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
```

En zsh, línea en `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Para comprobar la instalación, cerrad la terminal y abrid otra. Poned:

```bash
aws --version
```

Si devuelve una línea que empieza por `aws-cli/2`, la instalación está bien.

Con `sudo`, la instalación de sistema deja `aws` en `/usr/local/bin`, que ya suele estar en el `PATH`:

```bash
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system
```

La alternativa gráfica es el paquete [AWSCLIV2.pkg](https://awscli.amazonaws.com/AWSCLIV2.pkg).

### `aws configure`: los dos ficheros que genera

`aws configure` pide cuatro datos y los guarda en la carpeta `.aws` de vuestro usuario. No genera un solo fichero: genera **dos**.

| Pregunta | Valor en el curso |
| :--- | :--- |
| AWS Access Key ID | La access key que se os ha entregado |
| AWS Secret Access Key | La secret key que se os ha entregado |
| Default region name | `eu-west-1` |
| Default output format | `json` |

```bash
aws configure
```

Rutas:

| Sistema | Credenciales | Configuración |
| :--- | :--- | :--- |
| Linux y macOS | `~/.aws/credentials` | `~/.aws/config` |
| Windows | `%USERPROFILE%\.aws\credentials` | `%USERPROFILE%\.aws\config` |

`credentials` guarda **quién eres**. Solo las claves, bajo el perfil `[default]`:

```ini
[default]
aws_access_key_id = AKIA................
aws_secret_access_key = ........................................
```

`config` guarda **cómo llamas a la API**. La región y el formato de salida, también bajo `[default]`:

```ini
[default]
region = eu-west-1
output = json
```

El perfil `default` es el que usan la AWS CLI y el provider de AWS de Terraform cuando no indicáis otro. Por eso, en la siguiente clase, Terraform reutiliza estas claves: no hace falta exportar `AWS_ACCESS_KEY_ID` en cada terminal.

La secret key queda en texto claro dentro de `credentials`. Ese fichero no se copia a un repositorio. En Linux y macOS, `aws configure` lo deja con permisos de solo lectura para vuestro usuario.

### Comprobar que habéis asumido vuestro usuario

`aws sts get-caller-identity` llama a STS y pregunta a AWS qué identidad corresponde a las claves del perfil `default`. No crea ni modifica recursos.

```bash
aws sts get-caller-identity
```

La respuesta, con `output = json`, tiene esta forma:

```json
{
    "UserId": "AIDAEXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/ucm-ana_garcia"
}
```

El `Arn` tiene que terminar en `user/ucm-<vuestro identificador>`. Si termina en `root`, o en otro usuario, las claves no son las vuestras.

Errores habituales al pegar las claves:

| Mensaje | Causa típica |
| :--- | :--- |
| `InvalidClientTokenId` | El Access Key ID no existe o está mal copiado. |
| `SignatureDoesNotMatch` | La secret key no coincide. Suele colarse un espacio o un salto de línea al pegar. |
| `Unable to locate credentials` | `aws configure` no se ejecutó en este usuario, o la terminal es anterior a la instalación. |

Para reescribir las claves, volved a lanzar `aws configure`.

---

## Checklist

- [ ] VS Code tiene **Terraform** (Anton Kulikov) y **HashiCorp Terraform** (HashiCorp).
- [ ] `terraform --version` imprime `Terraform v1.15.9`.
- [ ] `aws --version` imprime `aws-cli/2`.
- [ ] `aws sts get-caller-identity` devuelve el ARN `user/ucm-...` de vuestro usuario.
