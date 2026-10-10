"""Publica la hora UTC en el topic SNS indicado por el entorno."""

import os
from datetime import datetime, timezone

import boto3


def lambda_handler(event, context):
    topic_arn = os.environ["SNS_TOPIC_ARN"]
    identificador = os.environ["IDENTIFICADOR_ALUMNO"]
    ahora = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    mensaje = f"Soy tu reloj de Amazon, son las {ahora}"

    boto3.client("sns").publish(
        TopicArn=topic_arn,
        Message=mensaje,
        Subject=f"Reloj UCM - {identificador}",
    )

    return {"statusCode": 200, "body": mensaje}
