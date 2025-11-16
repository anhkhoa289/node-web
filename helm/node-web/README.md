# Node.js Express Helm Chart

Helm chart để triển khai ứng dụng Node.js Express trên Kubernetes.

## Yêu cầu

- Kubernetes 1.19+
- Helm 3.0+
- Docker image được build bằng Cloud Native Buildpacks hoặc Dockerfile

## Build Image

Trước khi deploy, bạn cần build và push Docker image. Khuyến nghị sử dụng Cloud Native Buildpacks:

```bash
# Build với buildpack script
./scripts/build-and-push.sh node-web 1.0.0 docker.io/youruser

# Hoặc build với pack CLI
pack build docker.io/youruser/node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs

# Push image
docker push docker.io/youruser/node-web:1.0.0
```

## Cài đặt

### Cài đặt chart với image từ registry

```bash
helm install my-node-web ./helm/node-web \
  --set image.repository=docker.io/youruser/node-web \
  --set image.tag=1.0.0
```

### Cài đặt chart (nếu đã cập nhật values.yaml)

```bash
helm install my-node-web ./helm/node-web
```

### Cài đặt với custom values

```bash
helm install my-node-web ./helm/node-web -f custom-values.yaml
```

### Nâng cấp

```bash
helm upgrade my-node-web ./helm/node-web
```

### Gỡ cài đặt

```bash
helm uninstall my-node-web
```

## Cấu hình

Các tham số chính trong `values.yaml`:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Số lượng pod replicas | `2` |
| `image.repository` | Docker image repository | `node-web` |
| `image.tag` | Docker image tag | `1.0.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container port | `3000` |
| `ingress.enabled` | Enable ingress | `false` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `autoscaling.enabled` | Enable HPA | `false` |

## Ví dụ sử dụng

### Enable Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

### Enable Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Custom Environment Variables

```yaml
env:
  - name: NODE_ENV
    value: production
  - name: LOG_LEVEL
    value: info
```

## Health Checks

Chart này cấu hình sẵn:
- **Liveness probe**: Kiểm tra `/health` endpoint
- **Readiness probe**: Kiểm tra `/health` endpoint

## Security

Chart áp dụng các best practices về security:
- Pod chạy với non-root user
- Security context được cấu hình
- Resource limits được định nghĩa
- Read-only filesystem có thể được bật
