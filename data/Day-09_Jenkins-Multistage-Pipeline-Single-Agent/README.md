# 🚀 Day 09 — Jenkins Multistage Pipeline with Single Agent - Complete Guide

## 🎯 Overview

This guide demonstrates how to create a **multistage Jenkins pipeline** that runs all stages on a **single agent**. The pipeline builds a Node.js React application with multiple stages including checkout, dependency installation, testing, building, artifact archiving, and deployment.


## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/SfiBGJQdKGI/maxresdefault.jpg)](https://youtu.be/SfiBGJQdKGI)


### What is a Multistage Pipeline?

A multistage pipeline is a Jenkins pipeline that breaks down the CI/CD process into multiple discrete stages. Each stage represents a logical phase in the software delivery process.

### Single Agent vs Multiple Agents

- **Single Agent**: All stages run on the same Jenkins agent (node)
- **Multiple Agents**: Different stages can run on different agents based on requirements

---

## ✅ Prerequisites

Before you begin, ensure you have:

1. **Jenkins Server** installed and running
2. **Jenkins Agent** configured with label `sg` (or modify the pipeline to use `any`)
3. **Node.js** installed on the agent (version 16 or compatible)
4. **npm** installed on the agent
5. **Git** installed on the agent
6. Required Jenkins plugins:
   - Pipeline plugin
   - Git plugin
   - Workspace Cleanup plugin

---

### 🏗️ Pipeline Stages Breakdown

| Stage | Purpose | Key Actions |
|-------|---------|-------------|
| **Checkout** | Clone source code | Pulls code from GitHub repository |
| **Install Dependencies** | Setup project | Runs `npm install` to install packages |
| **Test** | Quality assurance | Executes `npm test` to run test suites |
| **Build** | Create artifacts | Runs `npm run build` to compile application |
| **Archive Artifacts** | Store build output | Archives build folder for future use |
| **Deploy (Demo)** | Deployment simulation | Demonstrates deployment process |

---

## 📝 Step-by-Step Implementation

### Step 1: Create a New Pipeline Job

1. Open Jenkins dashboard
2. Click **"New Item"**
3. Enter a name: `Day-09_Multistage-Single-Agent-Demo`
4. Select **"Pipeline"**
5. Click **"OK"**

### Step 2: Configure the Jenkins Agent

> [!IMPORTANT]
> Ensure you have a Jenkins agent with the label `sg` configured, or modify the pipeline to use `agent any`.

**To verify your agent:**
1. Go to **Manage Jenkins** → **Manage Nodes and Clouds**
2. Check if an agent with label `sg` exists
3. If not, either create one or change the pipeline to use `agent any`

### Step 3: Add the Pipeline Script

In the Pipeline configuration section, select **"Pipeline script"** and paste the following:

**Description**
```
<b>Demo Environment</b> <br>
<b>Git: </b> https://github.com/jenkins-docs/simple-node-js-react-npm-app.git <br>
<b>Branch: </b> master <br>
<b>Domain: </b> NA <br>
```

```groovy
pipeline {
    agent { label 'sg' }  // Use a specific agent labeled 'sg'
    // agent any  // Uncomment this to use any available agent
    
    environment {
        DEPLOY_ENV = "staging"
        APP_NAME = "simple-node-js-react-npm-app" 
        GIT_URL = "https://github.com/jenkins-docs/simple-node-js-react-npm-app.git"
        GIT_BRANCH = "master"
        // Tool paths
        NODE20_HOME     = "/tools/node20" // Adjust to match your app requirements
        DOCKER_HOME     = "/tools/docker"
        DOCKER_BUILDX   = "/tools/docker-buildx"
        // PATH Setup
        PATH = "${env.NODE20_HOME}/bin:" +
               "${env.DOCKER_HOME}:" +
               "${env.DOCKER_BUILDX}:" +
               "${env.PATH}"
    }
    // Global options
    options {
        timeout(time: 30, unit: 'MINUTES') // Set timeout to 30 minutes
        timestamps() // Add timestamps to console log
        //retry(2)   // Retries the whole pipeline if any stage fails.
        disableConcurrentBuilds() // Disable concurrent builds
    }

    stages {
        stage('Prepare Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
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
            steps {
                echo "🧪 Running tests..."
                sh "npm test"
            }
        }
        
        stage('Build') {
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                echo "🔧 Building app..."
                sh "npm run build"
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo "📁 Archiving build artifacts..."
                archiveArtifacts artifacts: 'build/**', fingerprint: true
            }
        }
        
        stage('Deploy (Demo)') {
            when {
                expression {
                    GIT_BRANCH == 'master'
                }
            }
            steps {
                echo "🚀 Deployment (demo step)..."
                sh "echo DEPLOY: pretend we deploy the app"
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
                        to: "team@example.com"
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
                        to: "team@example.com"
                    )
                } catch (e) {
                    echo "Email not configured, skipping failure notification"
                }
            }
        }

        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
    }
}
```

### Step 4: Save and Build

1. Click **"Save"**
2. Click **"Build Now"**
3. Monitor the pipeline execution in the **"Stage View"**

---

## 🧪 Testing the Pipeline

### Test Case 1: Successful Build

**Expected Behavior:**
- ✅ All stages execute in sequence
- ✅ Green checkmarks for each stage
- ✅ Build artifacts are archived
- ✅ Workspace is cleaned up

**How to Verify:**
1. Check the **Console Output** for success messages
2. Verify **Stage View** shows all stages passed
3. Check **Build Artifacts** section for archived files
4. Review the **post-build actions** logs

### Test Case 2: Simulating a Test Failure

**Modify the Test Stage:**
```groovy
stage('Test') {
    steps {
        echo "🧪 Running tests..."
        sh "npm test || exit 1"  // Force failure
    }
}
```

**Expected Behavior:**
- ❌ Pipeline stops at Test stage
- ❌ Red X appears on the Test stage
- ❌ Post-action "failure" block executes
- ✅ Workspace cleanup still occurs (always block)

### Test Case 3: Checking Environment Variables

Add this temporary stage to verify environment variables:

```groovy
stage('Verify Environment') {
    steps {
        echo "App Name: ${env.APP_NAME}"
        echo "Node Version: ${env.NODE_VERSION}"
        sh "node --version"
        sh "npm --version"
    }
}
```

### Test Case 4: Manual Approval (Optional)

Add an approval stage before deployment:

```groovy
stage('Approve Deployment') {
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
    }
}
```

---


## 🚨 Troubleshooting

### Problem: Agent Not Found

**Error Message:**
```
There are no nodes with the label 'sg'
```

**Solution:**
- Change `agent { label 'sg' }` to `agent any`
- Or configure an agent with the label 'sg'

### Problem: npm Command Not Found

**Error Message:**
```
sh: npm: command not found
```

**Solution:**
- Install Node.js and npm on the Jenkins agent
- Use a Docker agent with Node.js pre-installed:
  ```groovy
  agent {
      docker {
          image 'node:16'
      }
  }
  ```

### Problem: Permission Denied

**Error Message:**
```
Permission denied when running npm install
```

**Solution:**
- Check Jenkins user permissions on the agent
- Run: `sudo chown -R jenkins:jenkins /path/to/workspace`

### Problem: Workspace Not Cleaning

**Solution:**
- Ensure the **Workspace Cleanup Plugin** is installed
- Check post-action logs for cleanup errors
- Manually clean: **Manage Jenkins** → **Workspace** → **Wipe Out Workspace**

---

## ✨ Best Practices

### 1. **Use Meaningful Stage Names**
```groovy
// ✅ Good
stage('Install Dependencies') { ... }

// ❌ Bad
stage('Stage 2') { ... }
```

### 2. **Add Descriptive Echo Statements**
```groovy
steps {
    echo "🔧 Building application for production..."
    sh "npm run build"
}
```

### 3. **Handle Errors Gracefully**
```groovy
post {
    failure {
        emailext (
            subject: "Build Failed: ${env.JOB_NAME}",
            body: "Check console output at ${env.BUILD_URL}",
            to: "team@example.com"
        )
    }
}
```

### 4. **Use Environment Variables**
```groovy
environment {
    DEPLOY_ENV = "staging"
    API_URL = "https://api.staging.example.com"
}
```

### 5. **Implement Timeout Policies**
```groovy
options {
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
}
```


---

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Sample Node.js Repository](https://github.com/jenkins-docs/simple-node-js-react-npm-app)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)

---

## 🎓 Key Takeaways

> [!NOTE]
> **Single Agent Pipelines are perfect when:**
> - You have a small to medium-sized project
> - All build tools are available on one agent
> - You want faster execution without agent switching
> - You need simplified debugging and maintenance

> [!TIP]
> **Consider Multiple Agents when:**
> - You need specialized environments (Windows, Linux, Docker)
> - Different stages require different resources
> - You want parallel execution across multiple machines
> - You have security requirements (e.g., isolated build/deploy environments)

---

## 📞 Next Steps

1. ✅ Run the basic pipeline successfully
2. 🔧 Customize stages for your specific project
3. 📧 Add notifications (email, Slack, etc.)
4. 🔐 Integrate with credential management
5. 🚀 Add real deployment steps
6. 📊 Set up monitoring and metrics
7. 🔄 Implement automated rollback strategies

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

