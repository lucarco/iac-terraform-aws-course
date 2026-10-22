"""Publica en SNS cuando una tarea ECS del alumno pasa a RUNNING o STOPPED."""

import os

import boto3


def lambda_handler(event, context):
    detail = event.get("detail") or {}
    estado = detail.get("lastStatus", "DESCONOCIDO")
    identificador = os.environ["IDENTIFICADOR_ALUMNO"]
    tarea = (detail.get("taskArn") or "").rsplit("/", 1)[-1] or "desconocida"
    motivo = detail.get("stoppedReason") or ""

    lineas = [
        f"Alumno: {identificador}",
        f"Tarea: {tarea}",
        f"Estado: {estado}",
    ]
    if motivo:
        lineas.append(f"Motivo: {motivo}")
    mensaje = "\n".join(lineas)

    boto3.client("sns").publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject=f"ECS {identificador} {estado}"[:100],
        Message=mensaje,
    )
    print(mensaje)
    return {"statusCode": 200, "body": mensaje}
