provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Proyecto   = "microcredencial-ucm"
      Alumno     = var.identificador_alumno
      Gestionado = "terraform"
    }
  }
}
