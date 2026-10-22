# Bucket y catálogo. El workgroup ucm-proyecto-final es de la infra base.
# Cada CSV es una fila, sin cabecera. La tabla apunta al prefijo y Athena lista los objetos.
# Bucket S3 y catálogo Glue de los CSV consumidos por Athena.

resource "aws_s3_bucket" "datos" {
  bucket        = var.bucket_datos
  force_destroy = true
}

resource "aws_glue_catalog_database" "menus" {
  name = "ucm_${var.identificador_alumno}"
}
resource "aws_glue_catalog_table" "restaurantes" {
  name          = "restaurantes"
  database_name = aws_glue_catalog_database.menus.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL       = "TRUE"
    classification = "csv"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datos.bucket}/restaurantes/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "nombre"
      type = "string"
    }

    columns {
      name = "descripcion"
      type = "string"
    }

    columns {
      name = "maps_url"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "precios" {
  name          = "precios"
  database_name = aws_glue_catalog_database.menus.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL       = "TRUE"
    classification = "csv"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datos.bucket}/precios/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "restaurante_id"
      type = "string"
    }

    columns {
      name = "precio"
      type = "double"
    }

    columns {
      name = "momento"
      type = "timestamp"
    }
  }
}
