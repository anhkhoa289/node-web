# Cloud Native Buildpacks Guide

Hướng dẫn chi tiết về việc sử dụng Cloud Native Buildpacks để build ứng dụng Node.js Express.

## Buildpacks là gì?

Cloud Native Buildpacks (CNB) là một công nghệ cho phép chuyển đổi source code thành container images mà không cần viết Dockerfile. Buildpacks tự động:

- Phát hiện loại ứng dụng (Node.js, Python, Java, etc.)
- Cài đặt dependencies cần thiết
- Áp dụng best practices về security và performance
- Tạo optimized container image

## Lợi ích của Buildpacks

### 1. Đơn giản hóa
- Không cần viết và maintain Dockerfile
- Tự động phát hiện và cấu hình runtime
- Giảm thiểu configuration

### 2. Security
- Base images được maintain và update thường xuyên
- Automatic security patches
- CVE scanning tích hợp
- Non-root user by default

### 3. Performance
- Optimized layer caching
- Efficient dependency management
- Smaller image sizes
- Faster build times

### 4. Standardization
- Consistent builds across teams
- Same process từ dev đến production
- OCI-compliant images

### 5. Reproducibility
- Deterministic builds
- Bill of Materials (BOM) tự động
- Version tracking

## Cài đặt Pack CLI

### macOS
```bash
brew install buildpacks/tap/pack
```

### Linux/WSL
```bash
# Download và install
wget https://github.com/buildpacks/pack/releases/download/v0.32.1/pack-v0.32.1-linux.tgz
sudo tar -xzf pack-v0.32.1-linux.tgz -C /usr/local/bin
rm pack-v0.32.1-linux.tgz

# Verify installation
pack --version
```

### Windows
```powershell
# Với Chocolatey
choco install pack

# Hoặc download từ GitHub releases
# https://github.com/buildpacks/pack/releases
```

## Cấu trúc File Buildpack

### 1. project.toml
File cấu hình chính cho buildpack:

```toml
[_]
schema-version = "0.2"

# Chỉ định buildpacks cần dùng
[[io.buildpacks.group]]
id = "paketo-buildpacks/nodejs"

# Build-time environment variables
[build]
  [[build.env]]
  name = "BP_NODE_VERSION"
  value = "18.*"

# Runtime environment variables
[[io.buildpacks.build.env]]
name = "NODE_ENV"
value = "production"
```

### 2. Procfile
Định nghĩa process để chạy ứng dụng:

```
web: npm start
```

### 3. .npmrc (Optional)
Cấu hình NPM cho build process:

```
production=true
prefer-offline=false
optional=false
```

## Build Commands

### Basic Build

```bash
# Build với default settings
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs
```

### Build với Configuration File

```bash
# Sử dụng project.toml
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --descriptor project.toml
```

### Build với Environment Variables

```bash
# Override Node.js version
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs \
  --env BP_NODE_VERSION="20.*" \
  --env NODE_ENV=production
```

### Build với Cache

```bash
# Sử dụng cache image để speed up builds
pack build node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs \
  --cache-image node-web-cache
```

### Build và Push

```bash
# Build và push cùng lúc
pack build docker.io/youruser/node-web:1.0.0 \
  --builder paketobuildpacks/builder:base \
  --buildpack paketo-buildpacks/nodejs \
  --publish
```

## Paketo Buildpacks cho Node.js

Dự án này sử dụng Paketo Node.js buildpack. Các environment variables hữu ích:

### Node.js Version
```bash
--env BP_NODE_VERSION="18.*"  # Specific major version
--env BP_NODE_VERSION="18.17.1"  # Exact version
```

### NPM Configuration
```bash
--env BP_NODE_RUN_SCRIPTS="build"  # Run npm scripts
--env NPM_CONFIG_PRODUCTION=true  # Production install
```

### Build Optimization
```bash
--env BP_KEEP_FILES="package.json:package-lock.json"
--env BP_NODE_OPTIMIZE_MEMORY=true
```

## Build Scripts

Dự án cung cấp các scripts tiện lợi:

### 1. build-with-buildpack.sh

Build image locally:

```bash
./scripts/build-with-buildpack.sh [IMAGE_NAME] [TAG] [REGISTRY]

# Ví dụ
./scripts/build-with-buildpack.sh node-web 1.0.0
./scripts/build-with-buildpack.sh node-web 1.0.0 docker.io/youruser
```

### 2. build-and-push.sh

Build và push lên registry:

```bash
./scripts/build-and-push.sh [IMAGE_NAME] [TAG] [REGISTRY]

# Ví dụ
./scripts/build-and-push.sh node-web 1.0.0 docker.io/youruser

# Hoặc với environment variables
REGISTRY=docker.io/youruser IMAGE_TAG=1.0.0 ./scripts/build-and-push.sh
```

## Builders

Builders là base images chứa buildpacks. Các options phổ biến:

### Paketo Builders

```bash
# Base builder - balanced size
paketobuildpacks/builder:base

# Full builder - all buildpacks
paketobuildpacks/builder:full

# Tiny builder - minimal size (distroless)
paketobuildpacks/builder:tiny
```

### Heroku Builder

```bash
heroku/builder:22
```

### Google Cloud Platform

```bash
gcr.io/buildpacks/builder:v1
```

## Best Practices

### 1. Specify Node.js Version
Luôn chỉ định version trong `project.toml` hoặc `package.json`:

```json
{
  "engines": {
    "node": "18.x"
  }
}
```

### 2. Use package-lock.json
Đảm bảo có `package-lock.json` cho reproducible builds.

### 3. Production Dependencies
Chỉ install production dependencies:

```json
{
  "scripts": {
    "start": "node index.js"
  }
}
```

### 4. Health Checks
Implement health check endpoint:

```javascript
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});
```

### 5. Environment Variables
Use environment variables cho configuration:

```javascript
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
```

## Troubleshooting

### Build fails với "buildpack not found"

```bash
# Ensure builder và buildpack tồn tại
pack builder inspect paketobuildpacks/builder:base
```

### Node.js version mismatch

```bash
# Check Node.js version được detect
pack build node-web:1.0.0 --builder paketobuildpacks/builder:base --verbose
```

### Cache issues

```bash
# Clear cache
pack build node-web:1.0.0 --builder paketobuildpacks/builder:base --clear-cache
```

### Permission denied

```bash
# Ensure Docker daemon is running
docker ps

# Ensure pack CLI có quyền access Docker
docker run hello-world
```

## Advanced: Custom Buildpack

Nếu cần custom buildpack, tạo `buildpack.toml`:

```toml
[buildpack]
id = "my-custom-nodejs-buildpack"
version = "1.0.0"
name = "Custom Node.js Buildpack"

[[stacks]]
id = "io.buildpacks.stacks.bionic"
```

## Tài liệu tham khảo

- [Cloud Native Buildpacks](https://buildpacks.io/)
- [Paketo Buildpacks](https://paketo.io/)
- [Pack CLI Documentation](https://buildpacks.io/docs/tools/pack/)
- [Paketo Node.js Buildpack](https://github.com/paketo-buildpacks/nodejs)

## So sánh: Buildpack vs Dockerfile

| Aspect | Buildpack | Dockerfile |
|--------|-----------|------------|
| Complexity | Thấp | Cao hơn |
| Maintenance | Tự động | Thủ công |
| Security | Auto-patched | Manual updates |
| Standardization | Cao | Varies |
| Flexibility | Moderate | Cao |
| Learning Curve | Thấp | Moderate |

## Kết luận

Cloud Native Buildpacks cung cấp cách đơn giản, secure và standardized để build container images. Đây là lựa chọn tốt cho:

- Teams muốn giảm complexity
- Projects cần automatic security updates
- Organizations muốn standardize build process
- Developers không muốn maintain Dockerfiles

Tuy nhiên, Dockerfile vẫn hữu ích cho:
- Custom base images
- Complex multi-stage builds
- Special requirements không được buildpack support
