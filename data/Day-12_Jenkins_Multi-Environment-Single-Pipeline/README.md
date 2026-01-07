# 🚀 Day 12 — Multi Environment Single Pipeline (Docker Build and Push) - Complete Guide

## 📋 Overview

This project demonstrates a **multi-environment Jenkins pipeline** that builds and deploys a Node.js application to different environments (**dev**, **qa**, **uat**, **prod**) using a single pipeline with environment-specific configurations.

## 🎯 Key Features

- ✅ **Single Pipeline for Multiple Environments**: One Jenkinsfile handles all environments
- ✅ **Environment-Specific Builds**: Different Git branches and Docker registries per environment
- ✅ **Multi-Architecture Support**: Builds for multiple platforms using Docker Buildx
- ✅ **Automated Tagging**: Automatic versioning with build numbers and dates
- ✅ **Node.js Demo App**: Simple Express application that displays client IP and environment info


## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/m8fZmacU3H4/maxresdefault.jpg)](https://youtu.be/m8fZmacU3H4)


## 🔧 Application Details

### Node.js Application (app.js)

The demo application is a simple Express.js server that:
- Runs on **port 3000**
- Displays **client IP address**
- Shows current **environment** (dev/qa/uat/prod)
- Provides health check endpoint
- Returns server information (Node version, platform, uptime)

#### Available Endpoints:

| Endpoint | Description |
|----------|-------------|
| `GET /` | Main endpoint - returns full application info including client IP |
| `GET /health` | Health check endpoint |
| `GET /ip` | Returns only client IP and environment |

## 🐳 Docker Configuration

### Dockerfile

The Dockerfile uses a **multi-stage build**:

1. **Build Stage**: 
   - Uses `node:22.14.0-bookworm` as base image
   - Installs production dependencies
   - Copies application files

2. **Runtime Stage**:
   - Uses `node:22.14.0-slim` for smaller image size
   - Sets environment variable placeholder (`BUILD_CMD`)
   - Configures entrypoint script
   - Exposes port 3000

### Key Features:
- ✅ Multi-stage build for optimized image size
- ✅ Environment variable injection during build
- ✅ Proper entrypoint configuration
- ✅ Production-ready setup

### entrypoint.sh

The entrypoint script:
- Displays build information (build time, Jenkins build number, Git branch)
- Shows current environment
- Starts the Node.js application

## 🔄 Jenkins Pipeline Workflow

### Pipeline Parameters

The pipeline accepts one parameter:
- **ENVIRONMENT**: Choice parameter (dev/qa/uat/prod)

### Environment Configuration

| Environment | Git Branch | Docker Registry |
|-------------|-----------|-----------------|
| **dev** | development | `hub.devopsinaction.lab/dev/demo-image` |
| **qa** | qa | `hub.devopsinaction.lab/qa/demo-image` |
| **uat** | uat | `hub.devopsinaction.lab/uat/demo-image` |
| **prod** | production | `hub.devopsinaction.lab/prod/demo-image` |

### Pipeline Stages

Each environment has a dedicated stage that:

1. **Checks Environment**: Uses `when` condition to run only for selected environment
2. **Clones Repository**: Checks out environment-specific Git branch
3. **Docker Login**: Authenticates with Docker registry
4. **Creates Build Files**: 
   - Generates Dockerfile and entrypoint.sh
   - Replaces `BUILD_CMD` placeholder with environment name
   - Creates build_info file with metadata
5. **Builds Multi-Arch Image**: Uses Docker Buildx for platform support
6. **Pushes to Registry**: Tags and pushes images with version and latest tags


## 🔑 Required Credentials

The pipeline requires the following credentials configured in Jenkins:

| Credential ID | Description | Type |
|---------------|-------------|------|
| `d482446e-e815-4122-bf2d-a68ad17567b7` | Docker registry credentials | Username/Password |

## 🏃‍♂️ How to Use

### Prerequisites

1. Jenkins installed with required plugins:
   - Pipeline plugin
   - Git plugin
   - Credentials plugin
   - Docker plugin

2. Jenkins agent with label `sg`

3. Docker installed on Jenkins agent with Buildx support

4. Access to GitLab repository and Docker registry

### Setup Steps

1. **Manage Git Branches**:
   - https://github.com/meibraransari/nodejs-demo

   ```bash
   # Create branches 
   git checkout -b dev
   git checkout -b qa
   git checkout -b uat
   git checkout -b prod
   ```


2. **Configure Jenkins Credentials**:
   - Add Docker registry credentials in jenkins

3. **Create Jenkins Pipeline Job**:
   - Create new Pipeline job
   - Add choice parameter `ENVIRONMENT` with values: dev, qa, uat, prod
   - Copy the Jenkinsfile from RAEDME.md to pipeline script from [here](https://github.com/meibraransari/nodejs-demo/blob/main/jenkinsfile)

4. **Run the Pipeline**:
   - Select desired environment
   - Build with parameters

### Docker Testing

Build and run with Docker:

```bash
# Run container
docker run -p 3000:3000 hub.devopsinaction.lab/dev/demo-image 
# Override environment variables
docker run -id --name=demo -e ENVIRONMENT=dev -p 3000:3000 hub.devopsinaction.lab/dev/demo-image 

# Test endpoints
curl http://192.168.1.210:3000
curl http://192.168.1.210:3000/health
curl http://192.168.1.210:3000/ip
```

## 📊 Build Information

Each Docker image includes a `build_info` file containing:
- Build timestamp (Asia/Kolkata timezone)
- Jenkins build number
- Git branch name
- Check build information using below command
```bash
docker exec -it <CONTAINER_ID> cat /build_info
```

## 🎯 Benefits of This Approach

1. **Single Source of Truth**: One pipeline handles all environments
2. **Consistency**: Same build process across all environments
3. **Traceability**: Build metadata embedded in images
4. **Flexibility**: Easy to add new environments
5. **Automation**: Minimal manual intervention required
6. **Multi-Architecture**: Support for different platforms

## 🐛 Troubleshooting

### Common Issues:

1. **Docker login fails**:
   - Verify Docker credentials in Jenkins
   - Check Docker registry accessibility

2. **Buildx not available**:
   - Install Docker Buildx on Jenkins agent
   - Ensure QEMU is installed for multi-arch builds

3. **Git checkout fails**:
   - Verify GitLab credentials
   - Ensure branches exist in repository

4. **Application doesn't start**:
   - Check build_info file is created
   - Verify entrypoint.sh has execute permissions
   - Check Node.js dependencies are installed

---
## 🧠 About This Project

**Made with ❤️ for DevOps Engineers** 

Powered by **DevOps In Action**, this repository offers **real-world, hands-on DevOps setups** for CI/CD pipelines, containerization, Kubernetes, cloud platforms (AWS, GCP, Azure), and infrastructure at scale.

## 📝 License

This guide is provided as-is for educational and professional use.

## 🤝 Contributing

Feel free to suggest improvements or report issues.


### 💼 Connect with Me 👇😊

*   🔥 [**YouTube**](https://www.youtube.com/@DevOpsinAction?sub_confirmation=1)
*   ✍️ [**Blog**](https://ibraransari.blogspot.com/)
*   💼 [**LinkedIn**](https://www.linkedin.com/in/ansariibrar/)
*   👨‍💻 [**GitHub**](https://github.com/meibraransari?tab=repositories)
*   💬 [**Telegram**](https://t.me/DevOpsinActionTelegram)
*   🐳 [**Docker Hub**](https://hub.docker.com/u/ibraransaridocker)

### ⭐ If You Found This Helpful...

***Please star the repo and share it! Thanks a lot!*** 🌟
