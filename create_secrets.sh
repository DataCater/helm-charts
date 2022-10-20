#!/bin/bash

set +e
set -u

# shellcheck source=/dev/null
K8S_DISTRIBUTION=""
source .env

# Create namespace
kubectl create namespace "${DATACATER_NAMESPACE}"

# Create secrets
kubectl delete secret datacater-mailer-secret --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
kubectl create secret generic datacater-mailer-secret \
    --from-literal=host="${DATACATER_MAIL_SERVER}" \
    --from-literal=smtp_username="${DATACATER_MAIL_USER}" \
    --from-literal=password="${DATACATER_MAIL_PW}" \
    --from-literal=port="${DATACATER_MAIL_PORT}" \
    --namespace "${DATACATER_NAMESPACE}"

kubectl delete secret datacater-db-secret --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
kubectl create secret generic datacater-db-secret \
    --from-literal=pg_user="${DATACATER_DB_USER}" \
    --from-literal=pg_password="${DATACATER_DB_PW}" \
    --from-literal=pg_host="${DATACATER_DB_HOST}" \
    --from-literal=pg_port="${DATACATER_DB_PORT}" \
    --namespace "${DATACATER_NAMESPACE}"

kubectl delete secret datacater --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
kubectl create secret docker-registry datacater \
    --docker-server='images.datacater.io' \
    --docker-username="${DATACATER_REGISTRY_USER}" \
    --docker-password="${DATACATER_REGISTRY_PW}" \
    --docker-email="${DATACATER_REGISTRY_USER}" \
    --namespace "${DATACATER_NAMESPACE}"

kubectl delete secret datacater-docker --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
kubectl create secret generic datacater-docker \
    --from-literal=docker_registry_uri='https://images.datacater.io' \
    --from-literal=docker_registry_user="${DATACATER_REGISTRY_USER}" \
    --from-literal=docker_registry_password="${DATACATER_REGISTRY_PW}" \
    --namespace "${DATACATER_NAMESPACE}"

if [ -n "$K8S_DISTRIBUTION" ] && [ "$K8S_DISTRIBUTION" == "GCP" ]; then
    kubectl delete secret pipeline-registry --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
    kubectl create secret docker-registry pipeline-registry \
        --docker-server="${PIPELINE_REGISTRY}" \
        --docker-username="_json_key" \
        --docker-password="$(cat key.json)" \
        --docker-email="_json_key" \
        --namespace "${DATACATER_NAMESPACE}"
elif [ -n "$K8S_DISTRIBUTION" ] && [ "$K8S_DISTRIBUTION" == "AWS" ]; then
    echo "Retrieving AWS ECR Password by executing 'aws ecr get-login-password --region $AWS_REGION'."
    kubectl delete secret pipeline-registry --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
    kubectl create secret docker-registry pipeline-registry \
        --docker-server="${PIPELINE_REGISTRY}" \
        --docker-username="AWS" \
        --docker-password="$(aws ecr get-login-password --region $AWS_REGION)" \
        --docker-email="AWS" \
        --namespace "${DATACATER_NAMESPACE}"
elif [ -n "${PIPELINE_REGISTRY}" ]; then
    echo "Pipeline Registry is set to ${PIPELINE_REGISTRY}, setting Password and Username from environment variables"
    kubectl delete secret pipeline-registry --namespace "${DATACATER_NAMESPACE}" --ignore-not-found
    kubectl create secret docker-registry pipeline-registry \
        --docker-server="${PIPELINE_REGISTRY}" \
        --docker-username="$PIPELINE_REGISTRY_USER" \
        --docker-password="$PIPELINE_REGISTRY_PW" \
        --docker-email="$PIPELINE_REGISTRY_USER" \
        --namespace "${DATACATER_NAMESPACE}"
else
    echo "Env variable K8S_DISTRIBUTION is either not set or to a value other then AWS or GCP!"
    exit 1
fi
