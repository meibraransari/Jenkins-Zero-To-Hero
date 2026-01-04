# 🚀 Day 11 — Jenkins Multi-Platform Docker Build, Push and Deploy Pipeline - Complete Guide

## 📋 Overview

This guide demonstrates how to build **multi-platform Docker images** (supporting both ARM64 and AMD64 architectures) using Jenkins pipeline with **Docker Buildx**. Building multi-platform images ensures your containers run seamlessly across different CPU architectures, from development laptops (Apple Silicon, AMD processors) to production servers.

## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/9Z8qNSYfc6s/maxresdefault.jpg)](https://youtu.be/9Z8qNSYfc6s)

### 🆕 What's New in Day 11?

Building on Day 10's multi-agent pipeline, we're adding:
- **🏗️ Multi-Platform Docker Builds** - Create images for `linux/arm64` and `linux/amd64` simultaneously
- **🔨 Docker Buildx Integration** - Leverage Docker's advanced build capabilities
- **🌐 Cross-Architecture Support** - Deploy the same image across different CPU architectures

### 🛠️ Technologies Used

- **Agent None** - No global agent (specify per stage)
- **Agent 'sg'** - For building and pushing multi-platform Docker images
- **Agent 'mgmt'** - For SSH-based deployment
- **When Expression** - `when { expression { true/false } }` to enable/disable stages
- **Docker Buildx** - Multi-platform image builder
- **QEMU** - CPU emulator for cross-platform builds

---

## 🏗️ Architecture

The pipeline follows a multi-stage workflow with enhanced Docker build capabilities:

1. **Checkout** - Clone the source code from Git repository
2. **Prepare Environment** - Prepare build metadata and Dockerfile
3. **Build & Push Multi-Platform Docker Image** - Create and push images for multiple CPU architectures
4. **Deploy Over SSH** - Deploy the container to production server

---

## 🔹 Common Linux Architectures
When building multi-platform images, you specify the target architectures using the `--platform` flag. This allows a single image tag to point to multiple architecture-specific image manifests. Here are the most common architecture identifiers:

- **linux/amd64**        -> 64-bit x86 (most servers, PCs)
- **linux/386**          -> 32-bit x86 (legacy systems)
- **linux/arm64**        -> ARM 64-bit (Apple M1/M2, AWS Graviton)
- **linux/arm/v7**       -> ARM 32-bit (Raspberry Pi 3/4)
- **linux/arm/v6**       -> Older ARM (Raspberry Pi Zero)
- **linux/ppc64le**      -> IBM PowerPC (little-endian)
- **linux/s390x**        -> IBM Z / Mainframe
- **linux/riscv64**      -> RISC-V 64-bit

---

##  🔎 Tip: Check Supported Platforms
docker buildx inspect --bootstrap

---


## ⚙️ Jenkins Pipeline Configuration

### Step 1: Create a New Pipeline Job

1. Navigate to Jenkins Dashboard
2. Click **"New Item"**
3. Enter a name for your pipeline like: Day-11_Jenkins-Multi-platform_Docker_Build_Pipeline
4. Select **"Pipeline"**
5. Click **"OK"**

---

### Step 2: Configure Job Description and Dockerfile

In the Pipeline configuration section, add the following description:

**Description**
```
<b>Demo Environment</b> <br>
<b>Git: </b> https://github.com/jenkins-docs/simple-node-js-react-npm-app.git <br>
<b>Branch: </b> master <br>
<b>Domain: </b> NA <br>
```

---

#### 🐳 Dockerfile Configuration

The following multi-stage Dockerfile optimizes the build process by separating build and production stages:

This project is parameterized > Multi-line String Parameter 
Name: Dockerfile
Default Value:

```dockerfile
# ---------- Build stage ----------
FROM node:18-alpine AS build
WORKDIR /app
# Copy dependency files first (better caching)
COPY package*.json ./
# Install dependencies
RUN npm install
# Copy app source
COPY . .
# Build the React app
RUN npm run build
# ---------- Production stage ----------
FROM nginx:alpine
# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*
# Copy build output from previous stage
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/build_info /build_info
# Expose HTTP port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

---

### Step 3: Add Pipeline Script

In the Pipeline configuration section, select **"Pipeline script"** and paste the following:

> **💡 Key Changes from Day 10:**
> - Modified the **Build & Push Docker Image** stage to use Docker Buildx
> - Added `PLATFORMS="linux/arm64,linux/amd64"` environment variable for multi-platform support
> - Integrated QEMU for cross-architecture emulation

```groovy
pipeline {
    // agent { label 'sg' }  // Use a specific agent labeled 'sg'
    // agent any  // Uncomment this to use any available agent
    agent none

    environment {
        DEPLOY_ENV = "staging"
        APP_NAME = "simple-node-js-react-npm-app" 
        GIT_URL = "https://github.com/jenkins-docs/simple-node-js-react-npm-app.git"
        GIT_BRANCH = "master"
        // Docker details
        DOCKER_HOST_CREDENTIALS = credentials('d482446e-e815-4122-bf2d-a68ad17567b7')
        MY_DOCKER_HOST = 'hub.devopsinaction.lab'
        DATE = new Date().format('d.M.YY')
        DOCKER_IMAGE = 'hub.devopsinaction.lab/project-admin-panel-prod'
        DOCKER_IMAGE_TAG = "${DATE}.${BUILD_NUMBER}"
        DOCKER_LATEST_TAG ="latest"
        PLATFORMS="linux/arm64,linux/amd64"
        // Container details
        container_name = 'c-project-admin-panel-prod'
        container_EXT_port = '8000'
        container_INT_port = '80'
        // Prod server details
        PROD_SERVER_IP = '192.168.1.210'
        PROD_SERVER_USER = 'user'
        ENV_PATH = '/opt/project'
        ENV_NAME = 'project_admin_env'
        
    }
    // Global options
    options {
        timeout(time: 30, unit: 'MINUTES') // Set timeout to 30 minutes
        timestamps() // Add timestamps to console log
        //retry(2)   // Retries the whole pipeline if any stage fails.
        disableConcurrentBuilds() // Disable concurrent builds
    }

    stages {
        stage('Checkout') {
            when { expression { true } }
            agent { label 'sg' }
            options {
                retry(3)   // Retry this stage up to 3 times(Enable it if global Retry is off)
            }
            steps {
                echo "🧾 Checking out code..."
                git url: GIT_URL, branch: GIT_BRANCH
                script {
                    currentBuild.description = "Env=${DEPLOY_ENV}, Branch=${GIT_BRANCH}"
                }
            }
        }
        stage ('Prepare Environment') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                    echo 'Building the application ${env.JOB_NAME}...'
                    sh 'rm -rf ${workspace}'
                    //sh 'echo "$PACKAGE_JSON" | tee > package.json'
                    sh 'echo "$Dockerfile" | tee > Dockerfile'
                    sh 'rm -rf build_info'
                    sh 'TZ="Asia/Kolkata" date "+Build Time: %d-%m-%Y %H:%M:%S %Z" | tee -a build_info'
                    sh 'echo "Jenkins Build Number: ${BUILD_NUMBER}" | tee >> build_info'
                    sh 'echo "Git Branch: ${GIT_BRANCH}" | tee >> build_info'
                    
            }
        }
		stage('Build & push Docker Image') {
		    when { expression { true } }
		    agent { label 'sg' }
		    steps {
		        sh '''
		        # Login to private registry
		        echo $DOCKER_HOST_CREDENTIALS_PSW | docker login \
		          -u $DOCKER_HOST_CREDENTIALS_USR \
		          --password-stdin ${MY_DOCKER_HOST}

		        # Enable multi-arch support
		        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

		        # Remove existing builder if present
		        docker buildx rm multiarch-builder || true

		        # Create buildx builder for production
                docker buildx create --name multiarch-builder --use || docker buildx use multiarch-builder

		        # Bootstrap builder
		        docker buildx inspect --bootstrap

		        # Build and push multi-platform image
		        docker buildx build \
		          --platform=${PLATFORMS} \
		          --no-cache \
		          --push \
		          -t $DOCKER_IMAGE:$DOCKER_LATEST_TAG \
		          -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG .
		        '''
		    }
		}
        stage ('Deploy_Over_SSH') {  
            when { expression { true } }
            //when { expression { currentBuild.result == 'SUCCESS' } } // Execute only if the 'test' stage is successful
            agent { label 'mgmt' } 
            steps {
                script {
                    sshagent(['210-ssh-remote-server-mumbai-region']) {
                    echo 'Deploying the application....'
                    sh """
                    ssh -o StrictHostKeyChecking=no $PROD_SERVER_USER@$PROD_SERVER_IP << 'EOF'
                    docker ps -a
                    echo $DOCKER_HOST_CREDENTIALS_PSW | docker login -u $DOCKER_HOST_CREDENTIALS_USR --password-stdin ${MY_DOCKER_HOST}
                    sudo docker pull $DOCKER_IMAGE:$DOCKER_LATEST_TAG
                    sudo docker rm $container_name -f > /dev/null 2>&1
                    sleep 2
                    #docker run -d --restart=always  --name $container_name -v $ENV_PATH/$ENV_NAME:/usr/share/nginx/www/.env -p $container_EXT_port:$container_INT_port $DOCKER_IMAGE:$DOCKER_LATEST_TAG
                    docker run -d --restart=always  --name $container_name -p $container_EXT_port:$container_INT_port $DOCKER_IMAGE:$DOCKER_LATEST_TAG
                    exit
                    EOF
                    """
                    }
                }
            }  
        }
    }
    post {
        success {
            echo "🎉 Pipeline completed successfully!"
            script {
                try {
                    emailext(
                        subject: "Build Success: ${env.JOB_NAME}",
                        body: "Check console output at ${env.BUILD_URL}",
                        to: "jenkins@devopsinaction.lab"
                    )
                } catch (e) {
                    echo "Email not configured, skipping success notification"
                }
            }
        }

        failure {
            echo "❌ Pipeline failed."
            script {
                try {
                    emailext(
                        subject: "Build Failed: ${env.JOB_NAME}",
                        body: "Check console output at ${env.BUILD_URL}",
                        to: "jenkins@devopsinaction.lab"
                    )
                } catch (e) {
                    echo "Email not configured, skipping failure notification"
                }
            }
        }

        // always {
        //     echo "🧹 Cleaning workspace..."
        //     cleanWs()
        // }
    }
}
```

---

### Step 4: Save and Build

1. Click **"Save"**
2. Click **"Build Now"**
3. Monitor the pipeline execution in the **"Stage View"**


---

## 🔧 Troubleshooting

During the implementation of multi-platform Docker builds, we encountered **two critical issues**. Below are the detailed problems and their step-by-step solutions:

---
### ❌ Issue 1: Docker Buildx Command Not Found

**Problem:**
```
unknown command: docker buildx
```

This error occurs when the Docker CLI plugins are not available to the Jenkins agent, even though Docker Buildx is installed on the host system.

**✅ Solution: Mount Docker CLI Plugins to Jenkins Agent** 
```bash
# check buildx version with root user in agent
docker exec -it jenkins_agent docker buildx version
# check buildx version with jenkins user in agent
docker exec -it -u jenkins jenkins_agent docker buildx version

# Check buildx version on Host (Where agent is deployed)
docker buildx version
# Plugin must be installed on host
https://docs.docker.com/engine/install/ubuntu/


# Check plugin path on Host
docker info | grep -i plugin -A5
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.30.1
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v5.0.1
    Path:     /usr/libexec/docker/cli-plugins/docker-compose


# Pass cli-plugins in jenkins agent
cd /home/user/demo
nano compose.yaml
      - /usr/libexec/docker/cli-plugins:/home/jenkins/.docker/cli-plugins:rw

nano ./entrypoint.sh
# Add below line above of: # Important: Start sshd which will spawn new sessions with updated groups
mkdir -p /home/jenkins/.docker
chown -R jenkins:jenkins /home/jenkins/.docker

# Restart jenkins agent
docker compose down
docker compose up -d

# Verify node agent SSH key again
Jenkins > setting > node > sg > Trust SSH Host Key (Yes)

# check buildx version with root user in agent
docker exec -it jenkins_agent docker buildx version
# check buildx version with jenkins user in agent
docker exec -it -u jenkins jenkins_agent docker buildx version


```
> **🎯 Run Jenkins job again**


---
### ❌ Issue 2: BuildKit TLS Certificate Verification Failed

**Problem:**
```
ERROR: failed to build: failed to solve: failed to push hub.devopsinaction.lab/project-admin-panel-prod:latest: 
failed to do request: Head "https://hub.devopsinaction.lab/v2/": tls: failed to verify certificate: 
x509: certificate signed by unknown authority
```

This error happens when pushing to a private Docker registry with a self-signed certificate. Docker Buildx's BuildKit requires explicit configuration to trust insecure registries.

**✅ Solution: Configure BuildKit to Allow Insecure Registry**

```bash
# Add below in jenkins file above of Create buildx builder for production and comment production line
                # Create buildx configuration for insecure registry
                cat > /tmp/buildkitd.toml <<EOF
[registry."${MY_DOCKER_HOST}"]
  http = false
  insecure = true
EOF

		        # Create buildx builder for selfsigned sertificate
		        docker buildx create \
		          --name multiarch-builder \
		          --use \
		          --driver docker-container \
		          --driver-opt image=moby/buildkit:buildx-stable-1 \
		          --driver-opt network=host \
		          --config /tmp/buildkitd.toml \
		          --buildkitd-flags '--allow-insecure-entitlement security.insecure'

		        # Create buildx builder for production
                #docker buildx create --name multiarch-builder --use || docker buildx use multiarch-builder

```


> **🎯 Run Jenkins job again**

**🎉 Success!** Finally, we completed our first multi-platform Docker build pipeline with multiple agents on the 2nd try after resolving 2 critical errors.

---

## ✅ Verification

### 🐳 Verify Multi-Platform Docker Image

Check the Docker registry to confirm both ARM64 and AMD64 architectures are available:

```
https://hubdash.devopsinaction.lab/repo/project-admin-panel-prod/tag/latest
```

You should see multiple architecture manifests in the image details.

### 🌐 Verify Deployment

Access the deployed application using the production server IP and port:

```
http://192.168.1.210:8000/

# Check build information
docker exec -it <ID> cat /build_info
```

---

## 🎯 Key Takeaways

### 🐳 Multi-Platform Docker Builds
- **Docker Buildx** enables building images for multiple CPU architectures from a single pipeline
- **QEMU emulation** allows cross-compilation without native hardware for each architecture
- **Manifest lists** automatically serve the correct image variant based on the deployment target's architecture

### 🔧 Implementation Best Practices
- **Mount CLI Plugins** - Ensure Jenkins agents have access to Docker CLI plugins (buildx, compose)
- **Configure BuildKit** - Use custom `buildkitd.toml` for insecure/self-signed registry certificates
- **Platform Selection** - Define target platforms via environment variables for flexibility
- **Agent Assignment** - Use specialized agents for different stages (build vs deployment)

### 📦 Benefits
- **Universal Compatibility** - Single image works on ARM servers, AMD workstations, and cloud platforms
- **Future-Proof** - Supports emerging ARM-based infrastructure (AWS Graviton, Apple Silicon)
- **Cost Efficiency** - Deploy on cost-effective ARM instances without separate build pipelines
- **Developer Experience** - Seamless local development on different machines (Mac M1/M2, Linux AMD64)

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




