provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "ucm-iac"
      ManagedBy = "terraform"
      Taller    = "proyecto-final"
      Alumno    = var.identificador_alumno
    }
  }
}
