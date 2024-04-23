# Airbyte
Airbyte repo

## Install and Setup

### Helm

#### Add repo

```sh
helm repo add airbyte https://airbytehq.github.io/helm-charts
helm repo update
helm search repo airbyte
```

#### Setup Environment

```sh
export ENVIRONMENT=dev
export AIRBYTE_RELEASE=airbyte
```

#### Install

```sh
helm install $AIRBYTE_RELEASE airbyte/airbyte --namespace $ENVIRONMENT --create-namespace --version 0.64.241
```

#### Navigate

```sh
export POD_NAME=$(kubectl get pods --namespace $ENVIRONMENT -l "app.kubernetes.io/name=webapp" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace $ENVIRONMENT $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace $ENVIRONMENT port-forward $POD_NAME 8000:$CONTAINER_PORT
```

> - http://localhost:8000

### Docker

#### Install

```sh
# clone Airbyte from GitHub
git clone --depth=1 https://github.com/airbytehq/airbyte.git

# switch into Airbyte directory
cd airbyte

# start Airbyte
./run-ab-platform.sh
```

#### Navigate

> - http://localhost:8000
> - username: airbyte
> - password: password

## References

- https://airbyte.com/
- https://docs.airbyte.com/deploying-airbyte/on-kubernetes-via-helm

