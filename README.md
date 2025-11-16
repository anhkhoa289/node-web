# Node.js Express Application

Ứng dụng web Node.js với Express framework, sẵn sàng triển khai lên Kubernetes với Helm Chart.

## Tổng quan

Dự án này bao gồm:
- Ứng dụng Node.js Express cơ bản
- Hỗ trợ build với Cloud Native Buildpacks (khuyến nghị) hoặc Dockerfile
- Helm Chart để triển khai trên Kubernetes

## Cấu trúc dự án

```
node-web/
├── index.js                 # Entry point của ứng dụng
├── package.json            # Dependencies và scripts
├── Procfile                # Process definition cho buildpack
├── project.toml            # Buildpack configuration
├── .npmrc                  # NPM configuration
├── Dockerfile              # Docker image definition (backup option)
├── .dockerignore          # Docker ignore patterns
├── .gitignore             # Git ignore patterns
├── scripts/
│   ├── build-with-buildpack.sh   # Build script với Cloud Native Buildpacks
│   └── build-and-push.sh         # Build và push image
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
- Docker (để build và run image)
- **Pack CLI** (để build với Cloud Native Buildpacks - khuyến nghị)
- Kubernetes cluster (để deploy)
- Helm 3.0+ (để deploy với Helm)

### Cài đặt Pack CLI

```bash
# macOS
brew install buildpacks/tap/pack

# Linux/WSL
curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.32.1/pack-v0.32.1-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack

# Windows (Chocolatey)
choco install pack

# Hoặc tải từ: https://github.com/buildpacks/pack/releases
```

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

## Build Docker Image

### Phương pháp 1: Cloud Native Buildpacks (Khuyến nghị)

Buildpacks tự động phát hiện và build ứng dụng Node.js mà không cần Dockerfile, áp dụng best practices và tối ưu hóa image.

#### Build với script

```bash
# Build image cơ bản
./scripts/build-with-buildpack.sh node-web 1.0.0

# Build và push lên registry
./scripts/build-and-push.sh node-web 1.0.0 docker.io/youruser

# Hoặc dùng environment variables
REGISTRY=docker.io/youruser IMAGE_TAG=1.0.0 ./scripts/build-and-push.sh
```

#### Build thủ công với pack CLI

```bash
# Build với Paketo Node.js buildpack
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs \
  --env BP_NODE_VERSION="18.*"

# Build với custom builder
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --descriptor project.toml
```

#### Lợi ích của Buildpacks:
- Không cần viết Dockerfile
- Tự động áp dụng best practices
- Tự động cập nhật base image và dependencies
- Tối ưu hóa layer caching
- Security scanning tích hợp
- Reproducible builds

### Phương pháp 2: Dockerfile truyền thống

```bash
# Build với Dockerfile
docker build -t node-web:1.0.0 .
```

### Run Docker container

```bash
# Run với port mapping
docker run -p 3000:3000 node-web:1.0.0

# Run với environment variables
docker run -p 3000:3000 -e NODE_ENV=production node-web:1.0.0
```

## Kubernetes Deployment với Helm

### Quick Start

1. Build và push Docker image lên registry của bạn:

**Với Cloud Native Buildpacks (khuyến nghị):**
```bash
./scripts/build-and-push.sh node-web 1.0.0 docker.io/youruser
```

**Với Dockerfile:**
```bash
docker build -t docker.io/youruser/node-web:1.0.0 .
docker push docker.io/youruser/node-web:1.0.0
```

2. Deploy với Helm (image repository sẽ được override từ command line):

```bash
helm install my-node-web ./helm/node-web \
  --set image.repository=docker.io/youruser/node-web \
  --set image.tag=1.0.0
```

Hoặc cập nhật `helm/node-web/values.yaml` và deploy:

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
