# Airbyte

- Data Ingestion (Data Moviment)
- Extract & Load

> File path: /tmp/airbyte_local

## Laboratory

```sh
docker compose up
```

## Setup

### Install

https://docs.airbyte.com/using-airbyte/getting-started/oss-quickstart

#### abctl cli

```sh
curl -LsfS https://get.airbyte.com | bash -
```

### Run

```sh
abctl local install
```

### Credentials

* Setup

```sh
abctl local credentials --email meu@email.com
abctl local credentials --password Abc123
```

* View

```sh
abctl local credentials 
```



### Navigate

> - http://localhost:8000
> - username: airbyte
> - password: password


## Install and Setup

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

### Helm

#### Add repo

```sh
helm repo add airbyte https://airbytehq.github.io/helm-charts
```

```sh
helm repo update
```

```sh
helm search repo airbyte
```

#### Setup Environment

```sh
export ENVIRONMENT=data-ingestion
```

```sh
export AIRBYTE_RELEASE=airbyte
```

#### Install

```sh
helm install $AIRBYTE_RELEASE airbyte/airbyte --namespace $ENVIRONMENT --create-namespace --version 0.64.241
```

#### Navigate

```sh
export POD_NAME=$(kubectl get pods --namespace $ENVIRONMENT -l "app.kubernetes.io/name=webapp" -o jsonpath="{.items[0].metadata.name}")
```

```sh
export CONTAINER_PORT=$(kubectl get pod --namespace $ENVIRONMENT $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace $ENVIRONMENT port-forward $POD_NAME 8000:$CONTAINER_PORT
```

## References

- https://airbyte.com/
- https://docs.airbyte.com/deploying-airbyte/on-kubernetes-via-helm
