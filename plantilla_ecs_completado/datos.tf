# Bucket y catálogo. El workgroup ucm-proyecto-final es de la infra base.
# Cada CSV es una fila, sin cabecera. La tabla apunta al prefijo y Athena lista los objetos.
# El bucket y la base se declaran. Las tablas están comentadas.
# El storage_descriptor ya está; el type de cada columna, no.

# TODO: Descomentar y completar
# name, database_name, table_type, parameters y el type de cada columna.
# El storage_descriptor ya está.
# resource "aws_glue_catalog_table" "restaurantes" {
#   name          = "" # TODO: Completar
#   database_name = "" # TODO: Completar
#   table_type    = "" # TODO: Completar

#   parameters = {
#     EXTERNAL       = "" # TODO: Completar
#     classification = "" # TODO: Completar
#   }

#   storage_descriptor {
#     location      = "s3://${aws_s3_bucket.datos.bucket}/restaurantes/"
#     input_format  = "org.apache.hadoop.mapred.TextInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

#     ser_de_info {
#       serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

#       parameters = {
#         "field.delim"          = ","
#         "serialization.format" = ","
#       }
#     }

#     columns {
#       name = "id"
#       type = ""
#     }

#     columns {
#       name = "nombre"
#       type = ""
#     }

#     columns {
#       name = "descripcion"
#       type = ""
#     }

#     columns {
#       name = "maps_url"
#       type = ""
#     }
#   }
# }

# TODO: Descomentar y completar
# name, database_name, table_type, parameters y el type de cada columna.
# El storage_descriptor ya está.
# resource "aws_glue_catalog_table" "precios" {
#   name          = "" # TODO: Completar
#   database_name = "" # TODO: Completar
#   table_type    = "" # TODO: Completar

#   parameters = {
#     EXTERNAL       = "" # TODO: Completar
#     classification = "" # TODO: Completar
#   }

#   storage_descriptor {
#     location      = "s3://${aws_s3_bucket.datos.bucket}/precios/"
#     input_format  = "org.apache.hadoop.mapred.TextInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

#     ser_de_info {
#       serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

#       parameters = {
#         "field.delim"          = ","
#         "serialization.format" = ","
#       }
#     }

#     columns {
#       name = "id"
#       type = ""
#     }

#     columns {
#       name = "restaurante_id"
#       type = ""
#     }

#     columns {
#       name = "precio"
#       type = ""
#     }

#     columns {
#       name = "momento"
#       type = ""
#     }
#   }
# }
