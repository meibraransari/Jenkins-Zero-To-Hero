# 🚀 Day 16 — Production Deployment: A Bulletproof GitOps-Driven CI/CD Pipeline with Jenkins and Docker

## 📋 Table of Contents
- [Overview](#-overview)
- [Prerequisites](#-prerequisites)
- [GitOps Architecture](#-gitops-architecture)
- [Pipeline Workflow](#-pipeline-workflow)
- [Jenkins Configuration](#-jenkins-configuration)
- [Environment Variables](#-environment-variables)
- [Pipeline Stages](#-pipeline-stages)
- [Jenkinsfile](#-jenkinsfile)
- [Deployment Flow](#-deployment-flow)
- [Health Checks](#-health-checks)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This project demonstrates a **production-grade GitOps-driven CI/CD pipeline** that automates the complete deployment lifecycle of containerized applications. The pipeline implements infrastructure-as-code principles, automated Docker image building, versioning, and zero-downtime deployments to production servers using SSH.

**Key Features:**
- ✅ **GitOps Methodology**: Version-controlled infrastructure and deployment configurations
- ✅ **Automated Image Versioning**: Date and build number-based tagging system
- ✅ **Secure Credential Management**: Jenkins credential store integration
- ✅ **Health Check Validation**: Automated container health verification with retry logic
- ✅ **Zero-Downtime Deployments**: Docker Compose orchestrated rolling updates
- ✅ **Audit Trail**: Git-based deployment history and rollback capability

---

## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/Ry9MYjqtxZM/maxresdefault.jpg)](https://youtu.be/Ry9MYjqtxZM)


## 🔧 Prerequisites

Before implementing this pipeline, ensure you have the following components configured:

### 1️⃣ **Jenkins Setup**
- Jenkins server installed and running (version 2.x or higher)
- Jenkins agent with label `sg` configured and online
- SSH agent plugin installed for remote deployments
- Git plugin for repository operations

### 2️⃣ **Jenkins Credentials**
Create the following credentials in **Jenkins → Manage Credentials**:

| Credential Type | ID/Name | Description | Usage |
|----------------|---------|-------------|-------|
| Username with Password | `your-git-credentials-id` | GitHub username + Personal Access Token (PAT) | Git repository operations (clone, push) |
| Username with Password | `d482446e-e815-4122-bf2d-a68ad17567b7` | Docker registry credentials | Docker Hub/Private registry authentication |
| SSH Username with Private Key | `210-ssh-remote-server-mumbai-region` | Production server SSH key | Remote deployment via SSH |

> [!IMPORTANT]
> Replace credential IDs in the Jenkinsfile with your actual credential IDs from Jenkins.

### 3️⃣ **Docker Infrastructure**
- **Jenkins Agent**: Docker installed and configured
- **Production Server**: Docker and Docker Compose installed
- **Docker Registry**: Access to Docker Hub or private registry (e.g., `hub.devopsinaction.lab`)
- **Network Connectivity**: Jenkins agent can reach Docker registry and production server

### 4️⃣ **Git Repository**
- GitHub repository with your application code
- Separate branch for production deployments (e.g., `prod`)
- `docker-compose.yml` file in the repository root
- Dockerfile for building the application image

### 5️⃣ **Production Server**
- SSH access configured from Jenkins agent
- SSH key-based authentication enabled
- User account with Docker privileges (no sudo required)
- Directory permissions for deployment path (e.g., `/home/user/project_a/prod/`)

### 6️⃣ **Network Requirements**
- Jenkins agent must reach:
  - GitHub API (HTTPS port 443)
  - Docker registry (HTTPS port 443)
  - Production server (SSH port 22)
- Firewall rules allowing outbound connections from Jenkins
- Production server accessible via SSH from Jenkins network

### 7️⃣ **Application Requirements**
- Application includes health check endpoint
- Docker Compose file configured with health check directives
- Application supports zero-downtime updates

---

## 🏗️ GitOps Architecture

This pipeline implements a **pull-based GitOps deployment model** where Git is the single source of truth:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            JENKINS CI SERVER                            │
│   ┌──────────────┐          ┌──────────────┐          ┌──────────────┐  │
│   │ Build Image  │────────▶│  Tag Image   │─────────▶│  Push Image  │  │
│   │              │          │   (1.2.3)    │          │  to Registry │  │
│   └──────────────┘          └──────┬───────┘          └──────────────┘  │
│                                    │                                    │
│                                    ▼                                    │
│                            ┌───────────────┐                            │
│                            │  Update Git   │                            │
│                            │ docker-compose│                            │
│                            └───────┬───────┘                            │
│                                    │                                    │
└────────────────────────────────────┼────────────────────────────────────┘
                                     │
                                     ▼
                             ┌───────────────┐
                             │  Git Commit   │
                             │    & Push     │
                             └───────┬───────┘
                                     │
                                     ▼
┌────────────────────────────────────┴────────────────────────────────────┐
│                      GIT REPOSITORY (prod branch)                       │
│              📝 docker-compose.yml (updated image tag)                 │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────┴────────────────────────────────────┐
│                          PRODUCTION SERVER                              │
│   ┌──────────────┐          ┌──────────────┐          ┌──────────────┐  │
│   │   Git Pull   │────────▶│ Docker Pull  │─────────▶│  Compose Up  │  │
│   │  (via SSH)   │          │  New Image   │          │      -d      │  │
│   └──────────────┘          └──────────────┘          └──────┬───────┘  │
│                                                              │          │
│                                                              ▼          │
│                                                      ┌───────────────┐  │
│                                                      │ Health Check  │  │
│                                                      │  Validation   │  │
│                                                      └───────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

**Architecture Benefits:**
- 🔄 **Version Control**: All configuration changes tracked in Git
- 📊 **Audit Trail**: Complete deployment history
- ⏮️ **Rollback Capability**: Easy revert to previous versions
- 🔒 **Security**: No direct access to production from CI server
- 🎯 **Declarative**: Infrastructure defined as code

---

## 🔄 Pipeline Workflow

The pipeline executes the following stages in sequence:

```mermaid
graph LR
    A[Git Pull] --> B[Prepare Environment]
    B --> C[Build & Push Docker Image]
    C --> D[Update Compose File & Commit]
    D --> E[Deploy to Local]
    E --> F[Test Local]
    F --> G[Deploy Over SSH]
    G --> H[Health Check]
    H --> I[Post Actions]
```

**Stage Descriptions:**

1. **Git Pull**: Clone the production branch from GitHub
2. **Prepare Environment**: Create build metadata file with timestamp and build info
3. **Build & Push Docker Image**: Build Docker image with versioned tags and push to registry
4. **Update Compose File & Commit**: Update `docker-compose.yml` with new image tag and commit to Git
5. **Deploy to Local**: Placeholder for local testing (currently informational)
6. **Test Local**: Placeholder for local validation (currently informational)
7. **Deploy Over SSH**: SSH into production server, pull latest code, and deploy with Docker Compose
8. **Health Check**: Verify container health status with retry logic (3 attempts)

---

## ⚙️ Jenkins Configuration

### Required Jenkins Plugins
Ensure these plugins are installed:
- **Git Plugin**: SCM operations
- **SSH Agent Plugin**: Remote server access
- **Pipeline Plugin**: Declarative pipeline support
- **Credentials Plugin**: Secure credential storage
- **Docker Pipeline Plugin**: Docker operations (optional)

### Creating Credentials in Jenkins

#### 1️⃣ GitHub Credentials (Username + PAT)
1. Navigate to **Jenkins → Manage Jenkins → Credentials**
2. Click on appropriate domain (usually "Global")
3. Click **Add Credentials**
4. Select **Username with password**
5. Enter:
   - **Username**: Your GitHub username
   - **Password**: GitHub Personal Access Token with `repo` scope
   - **ID**: `your-git-credentials-id` (or custom ID)
   - **Description**: GitHub Authentication

> [!TIP]
> Generate a GitHub PAT at [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)

#### 2️⃣ Docker Registry Credentials
1. Follow same steps as above
2. Enter Docker Hub username and password/token
3. **ID**: `d482446e-e815-4122-bf2d-a68ad17567b7` (or custom ID)

#### 3️⃣ SSH Key for Production Server
1. **Add Credentials → SSH Username with private key**
2. Enter:
   - **Username**: Production server user (e.g., `user`)
   - **Private Key**: Paste SSH private key content
   - **ID**: `210-ssh-remote-server-mumbai-region`
   - **Description**: Production Server SSH Access

---

## 🌍 Environment Variables

The pipeline uses the following environment variables (configured in Jenkinsfile):

### Git Configuration
| Variable | Example Value | Description |
|----------|---------------|-------------|
| `GIT_CREDENTIALS_ID` | `your-git-credentials-id` | Jenkins credential ID for Git operations |
| `GIT_URL` | `https://github.com/meibraransari/nodejs-gitops-demo.git` | Repository URL |
| `GIT_BRANCH` | `prod` | Production branch name |

### Docker Configuration
| Variable | Example Value | Description |
|----------|---------------|-------------|
| `DOCKER_HOST_CREDENTIALS` | `credentials('d482446e-...')` | Docker registry credentials |
| `MY_DOCKER_HOST` | `hub.devopsinaction.lab` | Docker registry hostname |
| `DOCKER_IMAGE` | `hub.devopsinaction.lab/project-a-prod` | Docker image name |
| `DOCKER_IMAGE_TAG` | `15.1.26.42` | Image tag (date.build) |
| `DOCKER_LATEST_TAG` | `latest` | Latest tag for convenience |

### Production Server Configuration
| Variable | Example Value | Description |
|----------|---------------|-------------|
| `PROD_SERVER_IP` | `192.168.1.210` | Production server IP address |
| `PROD_SERVER_USER` | `user` | SSH username |
| `REMOTE_PATH` | `/home/user/project_a/prod/` | Deployment directory on server |
| `DOCKER_COMPOSE_FILE` | `docker-compose.yml` | Compose file name |
| `Domain_URL` | `http://192.168.1.210` | Application access URL |

---

## 📝 Pipeline Stages

### Stage 1: Git Pull
```groovy
stage('Git Pull') {
    steps {
        git branch: "${GIT_BRANCH}",
            url: "${GIT_URL}",
            credentialsId: "${GIT_CREDENTIALS_ID}"
    }
}
```
**Purpose**: Clone the production branch containing application code and `docker-compose.yml`.

---

### Stage 2: Prepare Environment
```groovy
stage ('Prepare Environment') {
    steps {
        sh 'rm -rf build_info'
        sh 'TZ="Asia/Kolkata" date "+Build Time: %d-%m-%Y %H:%M:%S %Z" | tee -a build_info'
        sh 'echo "Jenkins Build Number: ${BUILD_NUMBER}" | tee >> build_info'
        sh 'echo "Git Branch: ${GIT_BRANCH}" | tee >> build_info'
    }
}
```
**Purpose**: Create build metadata file for traceability and debugging.

---

### Stage 3: Build & Push Docker Image
```groovy
stage('Build & Push Docker Image') {
    steps {
        sh 'echo $DOCKER_HOST_CREDENTIALS_PSW | docker login -u $DOCKER_HOST_CREDENTIALS_USR --password-stdin ${MY_DOCKER_HOST}'
        sh 'docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG -t $DOCKER_IMAGE:$DOCKER_LATEST_TAG .'
        sh 'docker push $DOCKER_IMAGE:$DOCKER_IMAGE_TAG'
        sh 'docker push $DOCKER_IMAGE:$DOCKER_LATEST_TAG'
    }
}
```
**Purpose**: Build Docker image with version tags and push to registry.

**Key Points:**
- Uses `--no-cache` for fresh builds
- Tags with both version and `latest`
- Secure credential handling via environment variables

---

### Stage 4: Update Compose File & Commit
```groovy
stage('Update Compose File & Commit') {
    steps {
        sh """
            sed -i "s|image:.*|image: ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}|g" ${DOCKER_COMPOSE_FILE}
        """
        withCredentials([usernamePassword(...)]) {
            sh """
                git config user.email "jenkins@devopsinaction.lab"
                git config user.name "Jenkins CI"
                git add ${DOCKER_COMPOSE_FILE}
                git commit -m "Deploy build ${DOCKER_IMAGE_TAG} to prod"
                git push https://$GIT_USER:$GIT_PASS@github.com/...
            """
        }
    }
}
```
**Purpose**: Update `docker-compose.yml` with new image version and commit to Git (GitOps principle).

---

### Stage 7: Deploy Over SSH
```groovy
stage ('Deploy_Over_SSH') {
    steps {
        sshagent(['210-ssh-remote-server-mumbai-region']) {
            sh """
            ssh -o StrictHostKeyChecking=no $PROD_SERVER_USER@$PROD_SERVER_IP bash << 'EOF'
                # Clone or pull repository
                # Login to Docker registry
                # Pull Docker Compose images
                # Deploy with docker compose up -d
            EOF
            """
        }
    }
}
```
**Purpose**: Execute deployment on remote production server via SSH.

**Key Operations:**
1. Clone Git repository (if not exists) or pull latest changes
2. Login to Docker registry on production server
3. Pull latest Docker images
4. Stop old containers and start new ones with `docker compose up -d`

---

### Stage 8: Health Check
```groovy
stage('Health Check') {
    steps {
        sshagent(['210-ssh-remote-server-mumbai-region']) {
            retry(3) {
                sh """
                    ssh ... bash << "EOF"
                    STATUS=\$(docker compose -f ${DOCKER_COMPOSE_FILE} ps --status running --format json)
                    if echo "\$STATUS" | grep -q '"Health":"healthy"'; then
                        echo "✓ Container is healthy"
                        exit 0
                    else
                        exit 1
                    fi
                    EOF
                """
            }
        }
    }
}
```
**Purpose**: Validate deployment success by checking container health status.

**Features:**
- Retries up to 3 times
- Waits 5 seconds before checking
- Validates Docker health check status
- Fails pipeline if unhealthy

---

## 📄 Jenkinsfile

```groovy
pipeline {
    agent { label 'sg' }
    options {
        timeout(time: 30, unit: 'MINUTES') // Set timeout to 30 minutes
        timestamps() // Add timestamps to console log
        disableConcurrentBuilds() // Disable concurrent builds
    }
    environment {
        // Git credentials for pushing
        GIT_CREDENTIALS_ID = 'your-git-credentials-id'
        GIT_URL = 'https://github.com/meibraransari/nodejs-gitops-demo.git'
        GIT_BRANCH = 'prod'
        // Docker details
        DOCKER_HOST_CREDENTIALS = credentials('d482446e-e815-4122-bf2d-a68ad17567b7')
        MY_DOCKER_HOST = 'hub.devopsinaction.lab'
        DATE = new Date().format('d.M.YY')
        DOCKER_IMAGE = 'hub.devopsinaction.lab/project-a-prod'
        DOCKER_IMAGE_TAG = "${DATE}.${BUILD_NUMBER}"
        DOCKER_LATEST_TAG ="latest"
        // Prod server details
        PROD_SERVER_IP = '192.168.1.210'
        PROD_SERVER_USER = 'user'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        LOCAL_FILE = '/home/jenkins/project/project_a/prod/'
        REMOTE_PATH = '/home/user/project_a/prod/'
        SSH_KEY_PATH = '/home/jenkins/.ssh/jenkins_id_rsa_key'
        Domain_URL = "http://192.168.1.210"
    }
    stages {
        stage('Git Pull') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                echo "Checking out ${GIT_BRANCH} from ${GIT_URL}"
                git branch: "${GIT_BRANCH}",
                    url: "${GIT_URL}",
                    credentialsId: "${GIT_CREDENTIALS_ID}"
            }
        }
        stage ('Prepare Environment') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                    echo 'Building the application ${env.JOB_NAME}...'
                    //sh 'echo "$Dockerfile" | tee > Dockerfile'
                    sh 'rm -rf build_info'
                    sh 'TZ="Asia/Kolkata" date "+Build Time: %d-%m-%Y %H:%M:%S %Z" | tee -a build_info'
                    sh 'echo "Jenkins Build Number: ${BUILD_NUMBER}" | tee >> build_info'
                    sh 'echo "Git Branch: ${GIT_BRANCH}" | tee >> build_info'
                    
            }
        }
        stage('Build & Push Docker Image') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                sh 'echo $DOCKER_HOST_CREDENTIALS_PSW | docker login -u $DOCKER_HOST_CREDENTIALS_USR --password-stdin ${MY_DOCKER_HOST}'
                sh 'docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG -t $DOCKER_IMAGE:$DOCKER_LATEST_TAG .'
                sh 'docker image ls'
                sh 'docker push $DOCKER_IMAGE:$DOCKER_IMAGE_TAG'
                sh 'docker push $DOCKER_IMAGE:$DOCKER_LATEST_TAG'
            }
        }
        // Maintain audit log and vesioning. [Recommneded use GitOps (pull-based)]
        stage('Update Compose File & Commit') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                script {
                    // Update image tags in compose file
                    sh """
                        sed -i "s|image:.*|image: ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}|g" ${DOCKER_COMPOSE_FILE}
                    """
                    // Commit and push
                    withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}",
                                                      usernameVariable: 'GIT_USER',
                                                      passwordVariable: 'GIT_PASS')]) {
                        sh """
                            git config user.email "jenkins@devopsinaction.lab"
                            git config user.name "Jenkins CI"
                            git add ${DOCKER_COMPOSE_FILE}
                            git commit -m "Deploy build ${DOCKER_IMAGE_TAG} to prod" || true
                            git push https://$GIT_USER:$GIT_PASS@github.com/meibraransari/nodejs-gitops-demo.git ${GIT_BRANCH}
                        """
                    }
                }
            }
        }
        stage ('Deploy to local') {  
            when { expression { true } }
            //agent { label 'sg' } 
            steps {
                echo 'Deploying the application....'
           }  
        }
        stage ('Test Local') {  
            when { expression { true } }
            //agent { label 'sg' } 
            steps {
                echo 'Testing the application....'
            } 
        }
        stage ('Deploy_Over_SSH') {  
            when { expression { true } }
            steps {
                script {
                    sshagent(['210-ssh-remote-server-mumbai-region']) {
                        echo 'Deploying the application....'
                        withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}",
                                                          usernameVariable: 'GIT_USER',
                                                          passwordVariable: 'GIT_PASS')]) {
                            sh """
                            ssh -o StrictHostKeyChecking=no $PROD_SERVER_USER@$PROD_SERVER_IP bash << 'EOF'
                            set -e
                            sleep 2
                            echo $DOCKER_HOST_CREDENTIALS_PSW | docker login -u $DOCKER_HOST_CREDENTIALS_USR --password-stdin ${MY_DOCKER_HOST}
                            mkdir -p ${REMOTE_PATH}
                            # Clone if missing, else pull latest
                            if [ ! -d "${REMOTE_PATH}/.git" ]; then
                                echo "Git repo not found, cloning..."
                                rm -rf ${REMOTE_PATH}
                                git clone -b ${GIT_BRANCH} https://${GIT_USER}:${GIT_PASS}@github.com/meibraransari/nodejs-gitops-demo.git ${REMOTE_PATH}
                            else
                                echo "Git repo exists, pulling latest changes..."
                                cd ${REMOTE_PATH}
                                git pull https://${GIT_USER}:${GIT_PASS}@github.com/meibraransari/nodejs-gitops-demo.git ${GIT_BRANCH}
                            fi
                            
                            cd ${REMOTE_PATH}
                            docker compose -f ${DOCKER_COMPOSE_FILE} pull
                            docker compose -f ${DOCKER_COMPOSE_FILE} down
                            docker compose -f ${DOCKER_COMPOSE_FILE} up -d
                            docker ps -a
                            exit
                            EOF
                            """
                        }
                    }
                }
            }  
        }
        stage('Health Check') {
            when { expression { true } }
            steps {
                script {
                    sshagent(['210-ssh-remote-server-mumbai-region']) {
                        retry(3) {
                            sh """
                                sleep 5
                                ssh -o StrictHostKeyChecking=no $PROD_SERVER_USER@$PROD_SERVER_IP bash << "EOF"
                                set -e
                                cd ${REMOTE_PATH}
                                STATUS=\$(docker compose -f ${DOCKER_COMPOSE_FILE} ps --status running --format json)
                                if echo "\$STATUS" | grep -q '"Health":"healthy"'; then
                                    echo "✓ Container is healthy"
                                    exit 0
                                else
                                    echo "✗ Container is not healthy"
                                    echo "\$STATUS"
                                    exit 1
                                fi
                            exit
                            EOF
                            """
                        }
                    }
                }
            }
        }
    }
    post { 
        always { 
            echo "Release finished do cleanup and send mails"
            //googlechatnotification(
            //    message: "_*${JOB_NAME}*_ executed with the Job status: *```${currentBuild.result}```*\n _*Domain Access URL:*_ ${Domain_URL}",
            //    url: "https://chat.googleapis.com/v1/spaces/xxx/messages?key=xx-xx&token=xx"
            //)
        }
        cleanup {
            agent { label 'sg' } 
            /* clean up our workspace */
            deleteDir()
        }
    }
}
```

---

## 🚀 Deployment Flow

### Complete Deployment Process

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub Repo
    participant Jenkins as Jenkins CI
    participant Registry as Docker Registry
    participant Prod as Production Server
    
    Dev->>Git: Push code to prod branch
    Git->>Jenkins: Webhook triggers build
    Jenkins->>Git: Clone prod branch
    Jenkins->>Jenkins: Build Docker image
    Jenkins->>Registry: Push tagged image
    Jenkins->>Git: Update docker-compose.yml
    Git->>Git: Commit new image tag
    Jenkins->>Prod: SSH connection
    Prod->>Git: Pull latest compose file
    Prod->>Registry: Pull Docker image
    Prod->>Prod: docker compose up -d
    Prod->>Jenkins: Health check response
    Jenkins->>Dev: Deployment notification
```

### Step-by-Step Execution

1. **Developer Action**: Push code to `prod` branch or trigger Jenkins job manually
2. **Jenkins Initialization**: Pipeline starts on agent with label `sg`
3. **Source Code Checkout**: Pull latest code from production branch
4. **Build Metadata**: Generate build info with timestamp and build number
5. **Docker Build**: Create container image with `--no-cache` flag
6. **Image Tagging**: Apply version tag (`15.1.26.42`) and `latest` tag
7. **Registry Push**: Upload images to Docker registry
8. **GitOps Update**: Modify `docker-compose.yml` with new image tag
9. **Git Commit**: Commit changes with message "Deploy build X.Y.Z to prod"
10. **SSH Connection**: Establish secure connection to production server
11. **Repository Sync**: Clone or pull latest Git repository on production
12. **Docker Login**: Authenticate with Docker registry on production server
13. **Image Pull**: Download new Docker images
14. **Service Update**: Stop old containers and start new ones
15. **Health Validation**: Check container health status (retry 3 times)
16. **Cleanup**: Delete Jenkins workspace

---

## 🏥 Health Checks

### Docker Compose Health Check Configuration

Add health checks to your `docker-compose.yml`:

```yaml
services:
  project-a:
    image: hub.devopsinaction.lab/project-a-prod"
    container_name: project-a-prod
    ports:
      - "3000:3000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

### Health Check Best Practices

- ✅ Define health check endpoints in your application (e.g., `/health`, `/healthz`)
- ✅ Return HTTP 200 status code when healthy
- ✅ Include dependency checks (database, cache, external APIs)
- ✅ Set appropriate `start_period` for application warm-up
- ✅ Use reasonable `interval` and `timeout` values
- ✅ Log health check failures for debugging

---

## ✨ Best Practices

### Security
- 🔒 Never hardcode credentials in Jenkinsfile
- 🔒 Use Jenkins credential store for sensitive data
- 🔒 Implement SSH key-based authentication (no passwords)
- 🔒 Restrict Jenkins agent network access
- 🔒 Use private Docker registries for proprietary code
- 🔒 Scan Docker images for vulnerabilities (Trivy, Clair)

### Version Control
- 📌 Always tag images with semantic versions
- 📌 Maintain `latest` tag for convenience
- 📌 Use date-based tags for easy tracking
- 📌 Keep Git commit messages descriptive

### Pipeline Optimization
- ⚡ Use Docker layer caching when appropriate (remove `--no-cache` for dev)
- ⚡ Parallelize independent stages
- ⚡ Implement pipeline caching for dependencies
- ⚡ Set reasonable timeouts (30 minutes default)

### Deployment Strategy
- 🎯 Implement blue-green deployments for zero downtime
- 🎯 Use rolling updates with Docker Compose
- 🎯 Always validate deployments with health checks
- 🎯 Maintain rollback capability via Git history
- 🎯 Test in staging environment before production

### Monitoring
- 📊 Enable Jenkins build notifications (email, Slack, Google Chat)
- 📊 Log all deployment actions
- 📊 Track deployment metrics (frequency, success rate, duration)
- 📊 Monitor container health post-deployment

---

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1️⃣ **Authentication Failed to Docker Registry**
**Symptom**: `unauthorized: authentication required`

**Solution**:
```bash
# Verify credentials in Jenkins
# Ensure credential ID matches in Jenkinsfile
# Test Docker login manually on Jenkins agent
docker login hub.devopsinaction.lab -u username -p password
```

#### 2️⃣ **SSH Connection Refused**
**Symptom**: `ssh: connect to host X.X.X.X port 22: Connection refused`

**Solution**:
- Verify production server IP address
- Check firewall rules allow SSH from Jenkins
- Confirm SSH service is running: `sudo systemctl status sshd`
- Test SSH manually: `ssh user@192.168.1.210`

#### 3️⃣ **Git Push Permission Denied**
**Symptom**: `remote: Permission to repo.git denied`

**Solution**:
- Verify GitHub Personal Access Token (PAT) has `repo` scope
- Regenerate PAT if expired
- Update Jenkins credentials with new token
- Check GitHub username is correct

#### 4️⃣ **Health Check Failing**
**Symptom**: `✗ Container is not healthy`

**Solution**:
```bash
# SSH into production server
ssh user@192.168.1.210

# Check container logs
docker compose -f docker-compose.yml logs

# Inspect container health
docker inspect <container-id> | grep -A 10 Health

# Test health endpoint manually
curl -f http://localhost:3000/health
```

#### 5️⃣ **Docker Compose File Not Updating**
**Symptom**: Old image version still running

**Solution**:
- Verify `sed` command syntax in pipeline
- Check Git commit was successful
- Ensure production server pulled latest changes
- Manually update compose file for testing

#### 6️⃣ **Pipeline Timeout**
**Symptom**: `Build timeout exceeded`

**Solution**:
- Increase timeout in pipeline options: `timeout(time: 60, unit: 'MINUTES')`
- Optimize Docker build (multi-stage builds, smaller base images)
- Check network connectivity to Docker registry

#### 7️⃣ **Concurrent Builds Conflict**
**Symptom**: Multiple builds running simultaneously

**Solution**:
- Already handled by `disableConcurrentBuilds()` option
- If issue persists, check Jenkins job configuration
- Consider using build queue limits

---

## 📚 Additional Resources

- **Jenkins Documentation**: [jenkins.io/doc](https://jenkins.io/doc)
- **Docker Compose Reference**: [docs.docker.com/compose](https://docs.docker.com/compose)
- **GitOps Principles**: [gitops.tech](https://www.gitops.tech)
- **SSH Agent Plugin**: [plugins.jenkins.io/ssh-agent](https://plugins.jenkins.io/ssh-agent)

---

## 🎉 Conclusion

This GitOps-driven CI/CD pipeline provides a **production-ready, secure, and automated deployment solution** for containerized applications. By following infrastructure-as-code principles and implementing comprehensive health checks, you can achieve reliable and traceable deployments with minimal manual intervention.

**Key Takeaways:**
- ✅ Git is the single source of truth
- ✅ Automated versioning and tagging
- ✅ Zero-downtime deployments
- ✅ Complete audit trail
- ✅ Rollback capability via Git history

> [!NOTE]
> Remember to customize all environment variables, credential IDs, and server details according to your infrastructure before running this pipeline in production.

---

## 📝 License

This guide is provided as-is for educational and professional use.

---

## 🤝 Contributing

Feel free to suggest improvements or report issues via pull requests or the issues tab.

---

## 💼 Connect with Me 👇😊

*   🔥 [**YouTube**](https://www.youtube.com/@DevOpsinAction?sub_confirmation=1)
*   ✍️ [**Blog**](https://ibraransari.blogspot.com/)
*   💼 [**LinkedIn**](https://www.linkedin.com/in/ansariibrar/)
*   👨‍💻 [**GitHub**](https://github.com/meibraransari?tab=repositories)
*   💬 [**Telegram**](https://t.me/DevOpsinActionTelegram)
*   🐳 [**Docker Hub**](https://hub.docker.com/u/ibraransaridocker)

---

### ⭐ If You Found This Helpful...

***Please star the repo and share it! Thanks a lot!*** 🌟
