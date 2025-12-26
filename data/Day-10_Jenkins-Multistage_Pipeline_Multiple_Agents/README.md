# 🚀 Day 10 — Jenkins Multistage Pipeline with Multiple Agents - Complete Guide

## 📋 Overview

This guide demonstrates how to create a Jenkins multistage pipeline that uses **multiple agents** for different stages. This approach allows you to distribute workloads across different Jenkins agents, optimizing resource utilization and enabling specialized environments for specific tasks.

We are going to use Day 9 jenkins pipeline in Day 10 with some improvements. In this example, we'll build and deploy a React application using:
- **Agent None** - Disable Global Agent
- **Agent 'sg'** - for building and pushing Docker images
- **Agent 'mgmt'** - for deployment via SSH
- **When Expression** - when { expression { true } } #To disable and enable stage

---

## 🏗️ Architecture

The pipeline follows a multi-stage workflow:
1. **Checkout** - Clone the source code
2. **Install Dependencies** - Install npm packages (Taken from day 9)
3. **Test** - Run automated tests (Taken from day 9)
4. **Build** - Build the React application (Taken from day 9)
5. **Prepare Environment** - Prepare build metadata and Dockerfile
6. **Build & Push Docker Image** - Create and push Docker image to registry
7. **Deploy Over SSH** - Deploy the container to production server

---

## ⚙️ Jenkins Pipeline Configuration

### Step 1: Create a New Pipeline Job

1. Navigate to Jenkins Dashboard
2. Click **"New Item"**
3. Enter a name for your pipeline like: Day-10_Jenkins-Multistage-Pipeline-Multiple-Agent
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
# Expose HTTP port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

---

### Step 3: Add Pipeline Script

In the Pipeline configuration section, select **"Pipeline script"** and paste the following:

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
        DOCKER_HOST_CREDENTIALS = credentials('a3c6d7ba-d97e-492a-a54a-3b68ff600407')
        MY_DOCKER_HOST = 'hub.devopsinaction.lab'
        DATE = new Date().format('d.M.YY')
        DOCKER_IMAGE = 'hub.devopsinaction.lab/project-admin-panel-prod'
        DOCKER_IMAGE_TAG = "${DATE}.${BUILD_NUMBER}"
        DOCKER_LATEST_TAG ="latest"
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
        stage('Install Dependencies') {
            when { expression { false } }
            agent { label 'sg' }
            options {
                retry(2)
                timeout(time: 5, unit: 'MINUTES')
            }
            steps {
                echo "📦 Installing dependencies..."
                sh 'node --version'
                sh "npm install"
            }
        }
        
        stage('Test') {
            when { expression { false } }
            agent { label 'sg' }
            steps {
                echo "🧪 Running tests..."
                sh "npm test"
            }
        }
        
        stage('Build') {
            when { expression { false } }   
            agent { label 'sg' }
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                echo "🔧 Building app..."
                sh "npm run build"
            }
        }
        stage('Archive Artifacts') {
            when { expression { false } }
            agent { label 'sg' }
            steps {
                echo "📁 Archiving build artifacts..."
                archiveArtifacts artifacts: 'build/**', fingerprint: true
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
                    sh 'echo "Git Branch: ${web_git_branch}" | tee >> build_info'
                    
            }
        }
        stage('Build & push Docker Image') {
            when { expression { true } }
            agent { label 'sg' }
            steps {
                sh 'whoami && pwd && hostname -I && docker ps -a'
                sh 'echo $DOCKER_HOST_CREDENTIALS_PSW | docker login -u $DOCKER_HOST_CREDENTIALS_USR --password-stdin ${MY_DOCKER_HOST}'
                sh 'docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_IMAGE_TAG -t $DOCKER_IMAGE:$DOCKER_LATEST_TAG .'
                //sh 'docker build --no-cache -t $DOCKER_IMAGE:$DOCKER_LATEST_TAG .'
                sh 'docker image ls'
                sh 'docker push $DOCKER_IMAGE:$DOCKER_IMAGE_TAG'
                sh 'docker push $DOCKER_IMAGE:$DOCKER_LATEST_TAG'
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

During the implementation, we encountered three issues. Below are the problems and their solutions:

---
### ❌ Issue 1: Docker Registry TLS Certificate Verification Failed
ERROR: a3c6d7ba-d97e-492a-a54a-3b68ff600407


### 🔐 Add docker credentials in jenkins

1. **Navigate to Jenkins Credentials**:
   ```
   Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials → Add Credentials
   ```

2. **Configure Credential**:
   - **Kind**: `Username with password`
   - **ID (Optional)**: `docker-registry` (use a memorable identifier)
   - **Description**: `docker-registry`
   - **Username**: `docker`
   - **Password**: `docker`

---

> Run Jenkins job again

---



### ❌ Issue 2: Docker Daemon Permission Denied

**Error:**
```bash
# In jenkins file this line throwing error
echo docker | docker login -u docker --password-stdin hub.devopsinaction.lab
# On Manual test from cli
docker exec -it -u jenkins jenkins_agent docker ps
or
docker exec -it jenkins_agent su - jenkins -c "docker ps"

Error output:
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/****.sock: Get "http://%2Fvar%2Frun%2F****.sock/v1.24/containers/json?all=1": dial unix /var/run/****.sock: connect: permission denied
```

**✅ Solution:**

Create an entrypoint script that adds the Jenkins user to the Docker socket group:

```bash
# on Host 192.168.1.210:22
cd /home/user/demo
nano ./entrypoint.sh
#!/bin/bash
set -e
# Add jenkins user to a group with same GID as docker socket
DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
# Check if group with this GID already exists
if ! getent group $DOCKER_SOCK_GID > /dev/null 2>&1; then
    groupadd -g $DOCKER_SOCK_GID docker_host
fi
# Add jenkins user to the group
usermod -aG $DOCKER_SOCK_GID jenkins
# Important: Start sshd which will spawn new sessions with updated groups
exec /usr/local/bin/setup-sshd "$@"


chmod +x entrypoint.sh

# Add this to compose.yaml
nano compose.yaml
    entrypoint: /entrypoint.sh  # ← Make sure this line is present
    # ... Cother config
    volumes:
      - ./entrypoint.sh:/entrypoint.sh

docker compose down
docker compose up -d


docker exec -it -u jenkins jenkins_agent docker ps
docker exec -it jenkins_agent su - jenkins -c "docker ps"

CONTAINER ID   IMAGE                                                    COMMAND                  CREATED         STATUS                            PORTS                                   NAMES
215cd4e93d09   jenkins/ssh-agent:jdk21                                  "/entrypoint.sh"         9 seconds ago   Up 8 seconds (health: starting)   0.0.0.0:2020->22/tcp, :::2020->22/tcp   jenkins_agent


# Verify node ajent SSH key again
Jenkins > setting > node > sg > Trust SSH Host Key (Yes)

```

> Run Jenkins job again


---

### ❌ Issue 3: Docker Registry TLS Certificate Verification Failed

**Error:**
```bash
echo docker | docker login -u docker --password-stdin hub.devopsinaction.lab
Error response from daemon: Get "https://hub.devopsinaction.lab/v2/": tls: failed to verify certificate: x509: certificate signed by unknown authority
```

**✅ Solution:**

Configure Docker to use the registry as an insecure registry on the production host (192.168.1.210):

```bash
# on Host 192.168.1.210:22
sudo nano /etc/docker/daemon.json

{
  "insecure-registries": ["hub.devopsinaction.lab"]
}


sudo systemctl restart docker
# Wait for agent node to connect to jenkins
```

> Run Jenkins job again

Finally we completed our first multistage pipeline with multiple agents on 4th try resolving 3 errors.

---

## ✅ Verify Deployment

Access the deployed application using the production server IP and port:

```
http://192.168.1.210:8000/
```


---
## 🎯 Key Takeaways

- **Multiple Agents**: Different stages can run on different Jenkins agents based on their labels (`sg` for build, `mgmt` for deployment)
- **Agent None**: Setting `agent none` at the pipeline level allows you to specify agents at the stage level
- **Conditional Execution**: Use `when { expression { true/false } }` to enable/disable stages dynamically
- **Error Handling**: Post-build actions handle success/failure scenarios with email notifications
- **Security**: Always handle credentials securely using Jenkins credential management

---

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Jenkins SSH Agent Plugin](https://plugins.jenkins.io/ssh-agent/)

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




