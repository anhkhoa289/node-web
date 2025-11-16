# Node.js Express Application

Ứng dụng web Node.js với Express framework, sẵn sàng triển khai lên Kubernetes với Helm Chart.

## Tổng quan

Dự án này bao gồm:
- Ứng dụng Node.js Express cơ bản
- Dockerfile để containerize ứng dụng
- Helm Chart để triển khai trên Kubernetes

## Cấu trúc dự án

```
node-web/
├── index.js                 # Entry point của ứng dụng
├── package.json            # Dependencies và scripts
├── Dockerfile              # Docker image definition
├── .dockerignore          # Docker ignore patterns
├── .gitignore             # Git ignore patterns
└── helm/
    └── node-web/          # Helm chart
        ├── Chart.yaml     # Chart metadata
        ├── values.yaml    # Default configuration
        ├── README.md      # Chart documentation
        └── templates/     # Kubernetes templates
            ├── _helpers.tpl
            ├── deployment.yaml
            ├── service.yaml
            ├── serviceaccount.yaml
            ├── ingress.yaml
            └── hpa.yaml
```

## Yêu cầu

- Node.js 18+ (cho local development)
- Docker (để build image)
- Kubernetes cluster (để deploy)
- Helm 3.0+ (để deploy với Helm)

## Development

### Cài đặt dependencies

```bash
npm install
```

### Chạy ứng dụng local

```bash
npm start
```

Ứng dụng sẽ chạy tại http://localhost:3000

### Development mode với auto-reload

```bash
npm run dev
```

### API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint

## Docker

### Build Docker image

```bash
docker build -t node-web:1.0.0 .
```

### Run Docker container

```bash
docker run -p 3000:3000 node-web:1.0.0
```

## Kubernetes Deployment với Helm

### Quick Start

1. Build và push Docker image lên registry của bạn:

```bash
docker build -t your-registry/node-web:1.0.0 .
docker push your-registry/node-web:1.0.0
```

2. Cập nhật `helm/node-web/values.yaml` với image repository:

```yaml
image:
  repository: your-registry/node-web
  tag: "1.0.0"
```

3. Deploy với Helm:

```bash
helm install my-node-web ./helm/node-web
```

### Kiểm tra deployment

```bash
# Xem status
helm status my-node-web

# Xem pods
kubectl get pods

# Xem services
kubectl get svc

# Test ứng dụng (nếu dùng ClusterIP)
kubectl port-forward svc/my-node-web 8080:80
curl http://localhost:8080
```

### Cấu hình nâng cao

Tạo file `custom-values.yaml`:

```yaml
replicaCount: 3

image:
  repository: your-registry/node-web
  tag: "1.0.0"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

env:
  - name: NODE_ENV
    value: production
```

Deploy với custom values:

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

## Tính năng Helm Chart

- **Auto-scaling**: Horizontal Pod Autoscaler dựa trên CPU/Memory
- **Health checks**: Liveness và Readiness probes
- **Security**: Pod security context, non-root user
- **Resource management**: CPU và memory limits/requests
- **Ingress**: Hỗ trợ ingress controller
- **Service Account**: Tự động tạo service account
- **Flexible configuration**: Dễ dàng customize qua values.yaml

## License

ISC
