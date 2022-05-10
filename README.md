# smol6s || smol-ernete-s

Tutorial Setup for Teaching k8s to Advanced Users

## Getting started

```sh
docker-compose up
```

- k8s-api: [https://localhost:7443/](https://localhost:7443/)
- swagger: [http://localhost:8080/](http://localhost:8080/)

### API Access - Recommended

If you want to access the k8s-api with credentials, locate `client.key`, `client.crt` & `client-cert-auth-ca.crt` in the following directory:

```sh
export PATH_TO_CERTS=$(docker volume inspect smol6s_k8s_certs | jq -r '.[] | .Mountpoint')
```

Then you can curl the k8s-api-server as follows:

```sh
curl https://localhost:7443/api \
--cacert ${PATH_TO_CERTS}/client-cert-auth-ca.crt \
--cert ${PATH_TO_CERTS}/client.crt \
--key ${PATH_TO_CERTS}/client.key
```

or use `kubectl`:

```sh
export KUBECONFIG=${PATH_TO_CERTS}/kubeconfig
kubectl proxy
```

### API Access - Lazy

Otherwise you can connect to the k8s-api with an already authenticated nginx proxy:

- nginx k8s-api proxy: [http://localhost:5443/](http://localhost:5443/)
