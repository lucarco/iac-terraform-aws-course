# GENERA EL RECURSO DE LA BUCKET S3
resource "aws_s3_bucket" "example" {
  bucket = var.nombre_proyecto

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
