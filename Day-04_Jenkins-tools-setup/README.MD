# Day 04: Jenkins Agent Tools Setup

This directory contains scripts and configurations to set up a comprehensive development environment on a Jenkins agent. It includes a shell script to install various build tools and a sample `Jenkinsfile` demonstrating how to use them in a pipeline.

## 🎯 Objective

To automate the installation of essential build tools (Java, Maven, Gradle, Node.js, Docker) on a Jenkins agent and configure a Jenkins pipeline to utilize these tools without relying on global system installations.

## 🛠️ Tools will be Installed

The `tools_setup.sh` script installs the following tools into a dedicated directory (`/home/user/demo/JENKINS_AGENT_DATA_DIR/tools`):

| Tool | Version | Description |
|------|---------|-------------|
| **OpenJDK** | 17.0.9_9 | Java Development Kit (Temurin) |
| **Maven** | 3.9.11 | Java build automation tool |
| **Gradle** | 7.3.3 | Build automation tool for multi-language software |
| **Node.js** | 22.18.0 & 20.11.0 | JavaScript runtime (LTS versions) |
| **Yarn** | 1.22.22 | JavaScript package manager |
| **Docker CLI** | 28.3.1 | Command-line interface for Docker |
| **Docker Buildx** | v0.29.1 | Docker CLI plugin for extended build capabilities |

## 🚀 Setup Instructions

### 1. Run the Setup Script
Execute the `tools_setup.sh` script on your Jenkins agent machine. This script will download and extract the tools to the configured directory.

```bash
#!/bin/bash
#
# =============================================================================
# Jenkins Agent Tools Setup Script
# =============================================================================
# Purpose:       Installs required developer tools on a Jenkins agent:
#                - Gradle
#                - Maven
#                - OpenJDK 17
#                - Docker CLI & Buildx
#                - Node.js 22 & 20
#                - Yarn
#                After installation, prints all versions for verification.
#
# Author:        @DevOpsInAction
# Version:       1.0.0
# Created:       2025-11-23
# Last Updated:  2025-11-23
# License:       MIT (or your preferred license)
#
# Notes:
#   - All tools are installed under: /home/user/demo/JENKINS_AGENT_DATA_DIR/tools
#   - Designed for Linux (Debian/Ubuntu) based Jenkins agent nodes.
#   - Script is idempotent: repeated runs will overwrite previous installations.
# =============================================================================

set -euo pipefail

echo "🔧 Starting Jenkins Agent Tools Setup..."

#############################################
# Configuration
#############################################
TOOLS_DIR="/home/user/demo/JENKINS_AGENT_DATA_DIR/tools"

GRADLE_VERSION="7.3.3"
MAVEN_VERSION="3.9.11"
JDK_VERSION="17.0.9_9"
DOCKER_VERSION="28.3.1"
BUILDX_VERSION="v0.29.1"
NODE22_VERSION="22.18.0"
NODE20_VERSION="20.11.0"
YARN_VERSION="1.22.22"

#############################################
# Directory Setup
#############################################
echo "📁 Initializing tools directory at $TOOLS_DIR ..."
echo ""
rm -rf "$TOOLS_DIR"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

#############################################
# Install Docker CLI
#############################################
echo "🐳 Installing Docker CLI $DOCKER_VERSION ..."
wget -q -O docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
tar -xzf docker.tgz
rm -f docker.tgz
chmod +x "$TOOLS_DIR/docker/docker"
#echo "✅ Docker installed successfully!"

#############################################
# Install Docker Buildx
#############################################
echo "🔧 Installing Docker Buildx $BUILDX_VERSION ..."
wget -q "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" \
     -O "$TOOLS_DIR/docker-buildx"
chmod +x "$TOOLS_DIR/docker-buildx"

#############################################
# Install Gradle
#############################################
echo "📦 Installing Gradle $GRADLE_VERSION ..."
wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
unzip -q "gradle-${GRADLE_VERSION}-bin.zip"
mv "gradle-${GRADLE_VERSION}" "$TOOLS_DIR/gradle"
rm "gradle-${GRADLE_VERSION}-bin.zip"

#############################################
# Install Maven
#############################################
echo "📦 Installing Maven $MAVEN_VERSION ..."
wget -q "https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip"
unzip -q "apache-maven-${MAVEN_VERSION}-bin.zip"
mv "apache-maven-${MAVEN_VERSION}" "$TOOLS_DIR/maven"
rm "apache-maven-${MAVEN_VERSION}-bin.zip"

#############################################
# Install Java 17 (OpenJDK)
#############################################
echo "📦 Installing OpenJDK 17 ..."
wget -q "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION//_/%2B}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"
tar -xzf "OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"
mv "jdk-${JDK_VERSION//_/+}" "$TOOLS_DIR/java"
rm "OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION}.tar.gz"


#############################################
# Install Node.js 22
#############################################
echo "📦 Installing Node.js $NODE22_VERSION ..."
cd "$TOOLS_DIR"
mkdir -p node22 && cd node22
wget -q "https://nodejs.org/dist/v${NODE22_VERSION}/node-v${NODE22_VERSION}-linux-x64.tar.xz"
tar -xf "node-v${NODE22_VERSION}-linux-x64.tar.xz" --strip-components=1
rm "node-v${NODE22_VERSION}-linux-x64.tar.xz"

#############################################
# Install Node.js 20
#############################################
echo "📦 Installing Node.js $NODE20_VERSION ..."
cd "$TOOLS_DIR"
wget -q "https://nodejs.org/dist/v${NODE20_VERSION}/node-v${NODE20_VERSION}-linux-x64.tar.xz"
tar -xf "node-v${NODE20_VERSION}-linux-x64.tar.xz"
mv "node-v${NODE20_VERSION}-linux-x64" node20
rm "node-v${NODE20_VERSION}-linux-x64.tar.xz"

#############################################
# Install Yarn
#############################################
echo "📦 Installing Yarn $YARN_VERSION ..."
cd "$TOOLS_DIR"
wget -q "https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz"
tar -xzf "yarn-v${YARN_VERSION}.tar.gz"
mv "yarn-v${YARN_VERSION}" yarn
rm "yarn-v${YARN_VERSION}.tar.gz"

#############################################
# Environment Setup
#############################################
echo "🔧 Setting environment variables ..."
export JAVA_HOME="$TOOLS_DIR/java"
export PATH="$JAVA_HOME/bin:$TOOLS_DIR/maven/bin:$TOOLS_DIR/gradle/bin:$TOOLS_DIR/docker:$TOOLS_DIR/yarn/bin:$PATH"


#############################################
# Print Installed Versions
#############################################
echo ""
echo "========================================="
echo "🚀 Installed Tools Versions"
echo "========================================="

echo -n "🔸 Java:        " && java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}'
echo -n "🔸 Maven:       " && mvn -version 2>&1 | grep "Apache Maven" | awk '{print $3}'
echo -n "🔸 Gradle:      " && "$TOOLS_DIR/gradle/bin/gradle" -v 2>/dev/null | grep "Gradle " | awk '{print $2}'
echo -n "🔸 Docker CLI:  " && "$TOOLS_DIR/docker/docker" --version | awk '{print $3}'
echo -n "🔸 Buildx:      " && "$TOOLS_DIR/docker-buildx" version | head -n1 | awk '{print $2}'
echo -n "🔸 Node.js 22:  " && "$TOOLS_DIR/node22/bin/node" -v
echo -n "🔸 Node.js 20:  " && "$TOOLS_DIR/node20/bin/node" -v
echo -n "🔸 Yarn:        " && "$TOOLS_DIR/yarn/bin/yarn" -v

echo "========================================="
echo "🎉 All tools installed and verified!"
echo "========================================="
```


```bash
chmod +x tools_setup.sh
./tools_setup.sh
```

> **Note:** The script installs tools to `/home/user/demo/JENKINS_AGENT_DATA_DIR/tools`. Ensure this directory is accessible by the Jenkins agent user.

### 2. Restart Jenkins Agent
After the tools are installed, you **must restart the Jenkins agent** for it to recognize any environment changes if you are relying on system PATH updates (though the provided Jenkinsfile uses absolute paths).

```bash
# Example command to restart agent via Docker
docker restart <jenkins-agent-container-name>
```

## 📄 Jenkinsfile Configuration

The provided `jenkinsfile` demonstrates how to reference these custom-installed tools within a Jenkins pipeline.

### Environment Variables
The pipeline explicitly defines `JAVA_HOME`, `MAVEN_HOME`, etc., pointing to the installation paths.

```groovy
pipeline {
    environment {
        // Tool paths
        JAVA_HOME       = "/tools/java"
        MAVEN_HOME      = "/tools/maven"
        GRADLE_HOME     = "/tools/gradle"
        NODE20_HOME     = "/tools/node20"
        NODE22_HOME     = "/tools/node22"
        YARN_HOME       = "/tools/yarn"
        DOCKER_HOME     = "/tools/docker"
        DOCKER_BUILDX   = "/tools/docker-buildx"
        // PATH
        PATH = "${env.JAVA_HOME}/bin:" +
               "${env.MAVEN_HOME}/bin:" +
               "${env.GRADLE_HOME}/bin:" +
               "${env.YARN_HOME}/bin:" +
               "${env.NODE22_HOME}/bin:" +
               "${env.DOCKER_HOME}:" +
               "${env.DOCKER_BUILDX}:" +
               "${env.PATH}"
    }

```

You can use full example of jenkinsfile from this repository.
```groovy
pipeline {
    agent { label 'sg' }
    // Global tools used in pipeline
    // tools {
    //     maven 'Maven'     // Jenkins Maven tool name (configure in Global Tools)
    //     gradle 'Gradle'   // Jenkins Gradle tool name (configure in Global Tools)
    // }
    environment {
        // Tool paths
        JAVA_HOME       = "/tools/java"
        MAVEN_HOME      = "/tools/maven"
        GRADLE_HOME     = "/tools/gradle"
        NODE20_HOME     = "/tools/node20"
        NODE22_HOME     = "/tools/node22"
        YARN_HOME       = "/tools/yarn"
        DOCKER_HOME     = "/tools/docker"
        DOCKER_BUILDX   = "/tools/docker-buildx"
        // PATH
        PATH = "${env.JAVA_HOME}/bin:" +
               "${env.MAVEN_HOME}/bin:" +
               "${env.GRADLE_HOME}/bin:" +
               "${env.YARN_HOME}/bin:" +
               "${env.NODE22_HOME}/bin:" +
               "${env.DOCKER_HOME}:" +
               "${env.DOCKER_BUILDX}:" +
               "${env.PATH}"
    }
    options {
        // Keep build logs for 30 days, max 50 builds
        buildDiscarder(logRotator(daysToKeepStr: '30', numToKeepStr: '50'))
        timestamps() // Adds timestamps to console log
    }
    stages {

        stage('Checkout') {
            when { expression { true } }
            steps {
                echo "🔄 Checking out source code..."
                git branch: 'main', url: 'https://github.com/meibraransari/Jenkins-Zero-To-Hero.git'
            }
        }

        stage('Verify Tools') {
            when { expression { true } }
            steps {
                echo "🛠 Verifying installed tools..."
                sh '''
                    echo "JAVA:"; java --version
                    echo "Maven:"; mvn -version
                    echo "Gradle:"; gradle -v
                    echo "Node:"; node -v
                    echo "Yarn:"; yarn -v
                    echo "Docker:"; docker --version
                    echo "Docker Buildx:"; docker-buildx version || echo "Buildx not found"
                '''
            }
        }

        stage('Build') {
            when { expression { true } }
            steps {
                echo "🏗 Building the project..."
                sh '''
                    echo "Executing Build stage..."
                    # Example: Gradle build
                    #gradle clean build -x test
                '''
            }
        }

        stage('Test') {
            when { expression { true } }
            steps {
                echo "🧪 Running tests..."
                sh '''
                    echo "Executing Test stage..."
                    # Example: Run tests using Maven
                    #mvn test
                '''
            }
        }

        stage('Docker Build & Push') {
            when { expression { true } }
            steps {
                echo "🐳 Building Docker image with Buildx..."
                sh '''
                    echo "Executing Docker Build & Push stage..."
                    # Initialize builder if it doesn't exist
                    #docker-buildx create --use --name mybuilder || echo "Builder already exists"
                    #docker-buildx inspect --bootstrap
                    
                    # Build multi-arch image
                    #docker-buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .
                '''
            }
        }
        stage('Cleanup') {
            steps {
                echo "🧹 Cleaning up workspace..."
                cleanWs()
            }
        }
    }

post {
        success {
            echo "✅ Pipeline completed successfully!"
            mail to: 'team@example.com',
                 subject: "Jenkins Build SUCCESS: ${currentBuild.fullDisplayName}",
                 body: "Good news! The build completed successfully.\n\nCheck console output at: ${env.BUILD_URL}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
            mail to: 'team@example.com',
                 subject: "Jenkins Build FAILURE: ${currentBuild.fullDisplayName}",
                 body: "The build failed. Please check the console output:\n${env.BUILD_URL}"
        }
        always {
            echo "🔔 Pipeline finished."
            // Optional: send a summary email
            // mail to: 'team@example.com',
            //      subject: "Jenkins Build Finished: ${currentBuild.fullDisplayName}",
            //      body: "Build finished (status: ${currentBuild.currentResult}). See details: ${env.BUILD_URL}"
        }
    }
}
```

### Pipeline Stages
The pipeline includes stages to:
1.  **Checkout**: Get source code.
2.  **Verify Tools**: Print versions of all installed tools to confirm setup.
3.  **Build**: Example build step (commented out).
4.  **Test**: Example test step (commented out).
5.  **Docker Build & Push**: Example Docker build using Buildx (commented out).

## 📝 Notes

-   **Idempotency**: The setup script is designed to be idempotent. Running it multiple times will overwrite existing installations with the specified versions.
-   **Paths**: If you modify the installation directory in `tools_setup.sh`, remember to update the paths in the `jenkinsfile` as well.



## 🧠 About This Project

This project is maintained by **DevOps In Action**, mainly focusing on practical, hands-on DevOps setups for CI/CD automation, containerization, and infrastructure management.


### 💼 Connect with Me 👇😊

*   🔥 [**YouTube**](https://www.youtube.com/@DevOpsinAction?sub_confirmation=1)
*   ✍️ [**Blog**](https://ibraransari.blogspot.com/)
*   💼 [**LinkedIn**](https://www.linkedin.com/in/ansariibrar/)
*   👨‍💻 [**GitHub**](https://github.com/meibraransari?tab=repositories)
*   💬 [**Telegram**](https://t.me/DevOpsinActionTelegram)
*   🐳 [**Docker Hub**](https://hub.docker.com/u/ibraransaridocker)

### ⭐ If You Found This Helpful...

***Please star the repo and share it! Thanks a lot!*** 🌟
