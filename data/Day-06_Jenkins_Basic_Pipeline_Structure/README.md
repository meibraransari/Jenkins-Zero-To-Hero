# 🚀 Jenkins Basic Pipeline Structure - Day 06

This directory contains **37 comprehensive Jenkinsfile examples** demonstrating various Jenkins pipeline patterns for daily DevOps use. Each example is a complete, standalone pipeline that can be used as-is or adapted to your needs.

## 📋 Table of Contents

- [Basic Pipeline Structure](#basic-pipeline-structure)
- [Docker & Agents](#docker--agents)
- [Parallel Execution](#parallel-execution)
- [Source Control & Triggers](#source-control--triggers)
- [Environment & Tools](#environment--tools)
- [Conditional Execution](#conditional-execution)
- [Error Handling & Control](#error-handling--control)
- [Artifacts Management](#artifacts-management)
- [Advanced Workflows](#advanced-workflows)
- [Security & Deployment](#security--deployment)
- [Notifications](#notifications)
- [Quick Reference](#quick-reference)

---

## Basic Pipeline Structure

### 0. Basic Jenkins Pipeline Structure
**File:** `Jenkinsfile-00-Basic_Structure`
- Complete reference guide for Jenkins Pipeline syntax
- All essential pipeline directives and options
- Agent configurations (any, none, label, Docker)
- Environment variables and credentials
- Parameters (string, boolean, choice, text, password)
- Triggers (cron, pollSCM, upstream)
- Options (timeout, retry, timestamps, buildDiscarder)
- Tools configuration (Maven, JDK, Gradle, etc.)
- Stages and steps structure
- Post-build actions (always, success, failure, cleanup)
- **Perfect for**: Learning complete pipeline syntax reference

### 1. Post Actions with Cleanup
**File:** `Jenkinsfile-01-Post-Actions-Cleanup`
- Demonstrates post-build actions and workspace cleanup
- Shows how to use `post` blocks: `always` and `cleanup`
- Comprehensive workspace cleanup including parallel execution workspaces

### 2. Parameters Pipeline
**File:** `Jenkinsfile-02-Parameters`
- Shows all parameter types: string, boolean, choice, text, password
- Demonstrates parameter access in pipeline steps
- Useful for parameterized builds

### 3. Timestamps and Docker
**File:** `Jenkinsfile-03-Timestamps-Docker`
- Shows `options { timestamps() }` configuration
- Demonstrates running pipeline in Docker container
- Uses Node.js Docker image

---

## Docker & Agents

### 4. Workspace Synchronization
**File:** `Jenkinsfile-04-Workspace-Sync`
- Demonstrates `reuseNode true` for workspace sharing
- Runs Docker container with same workspace as parent agent

### 5. Multiple Containers
**File:** `Jenkinsfile-05-Multiple-Containers`
- Shows using different Docker containers in different stages
- Backend with Node.js 18, Frontend with Node.js 20
- Uses `agent none` at pipeline level

### 6. Docker Agent Build
**File:** `Jenkinsfile-06-Docker-Build`
- Demonstrates Docker agent for specific build stage
- Mixed agent types (any + docker)

---

## Parallel Execution

### 7. Parallel Tests
**File:** `Jenkinsfile-07-Parallel-Tests`
- Demonstrates parallel test execution
- Unit and Integration tests running simultaneously
- Reduces overall pipeline execution time

### 8. Parallel Microservices Build
**File:** `Jenkinsfile-08-Parallel-Microservices`
- Building multiple microservices in parallel
- Sequential deployment after parallel builds
- Real-world microservices workflow

---

## Source Control & Triggers

### 9. Git Checkout
**File:** `Jenkinsfile-09-Git-Checkout`
- Explicit Git checkout stage
- Shows how to clone repositories in pipeline

### 10. SCM Polling
**File:** `Jenkinsfile-10-SCM-Polling`
- Demonstrates `triggers { pollSCM() }`
- Automatic build triggering
- Can be replaced with webhooks for efficiency

---

## Environment & Tools

### 11. Environment Variables
**File:** `Jenkinsfile-11-Environment-Variables`
- Shows custom environment variables
- Access to Jenkins built-in variables
- Environment-specific configuration

### 12. Tools Configuration (Maven)
**File:** `Jenkinsfile-12-Tools-Maven`
- Demonstrates `tools` directive
- Maven installation configuration
- Complete Maven build workflow

---

## Conditional Execution

### 13. Branch Condition
**File:** `Jenkinsfile-13-Branch-Condition`
- Uses `when { branch }` directive
- Conditional deployment to production
- Only runs on specific branches

### 14. Branch Script
**File:** `Jenkinsfile-14-Branch-Script`
- Branch-based logic using `script` block
- More complex conditional logic
- Multiple branch handling

---

## Error Handling & Control

### 15. Retry Mechanism
**File:** `Jenkinsfile-15-Retry`
- Demonstrates `retry()` for flaky operations
- Network calls, external service dependencies
- Configurable retry count

### 16. Timeout Configuration
**File:** `Jenkinsfile-16-Timeout`
- Shows `timeout()` for long-running operations
- Prevents hanging builds
- Configurable time units

### 17. Input/Manual Approval
**File:** `Jenkinsfile-17-Input-Approval`
- Manual approval before production deployment
- `input` step usage
- Human-in-the-loop workflows

---

## Artifacts Management

### 18. Archive Artifacts
**File:** `Jenkinsfile-18-Archive-Artifacts`
- Archive build artifacts for later use
- Fingerprinting for tracking
- Build output preservation

### 19. Copy Artifacts from Another Job
**File:** `Jenkinsfile-19-Copy-Artifacts`
- Copy artifacts from another Jenkins job
- Cross-project dependencies
- Artifact filtering

### 20. Copy and Deploy Artifacts
**File:** `Jenkinsfile-20-Copy-Deploy-Artifacts`
- Complete copy and deploy workflow
- Using `lastSuccessful()` selector
- Deployment pipeline pattern

### 21. Stash and Unstash
**File:** `Jenkinsfile-21-Stash-Unstash`
- Share files between different agents
- `stash` and `unstash` usage
- Multi-agent workflows

---

## Advanced Workflows

### 22. Python Virtual Environment
**File:** `Jenkinsfile-22-Python-Venv`
- Python virtual environment setup
- Dependency installation
- Testing with pytest

### 23. Trigger Child Job
**File:** `Jenkinsfile-23-Trigger-Child-Job`
- Trigger another Jenkins job
- Pass parameters to child job
- Wait for completion

### 24. Trigger Multiple Jobs
**File:** `Jenkinsfile-24-Trigger-Multiple-Jobs`
- Trigger multiple dependent jobs sequentially
- Propagate failures
- Complex workflow orchestration

### 25. Clean Workspace
**File:** `Jenkinsfile-25-Clean-Workspace`
- Workspace cleanup in post action
- `cleanWs()` usage
- Conditional cleanup based on build result

---

## Security & Deployment

### 26. Docker Security Scan
**File:** `Jenkinsfile-26-Docker-Security-Scan`
- Security scanning with Trivy
- Docker image vulnerability detection
- Security-first CI/CD

### 27. Multi-Cloud Deployment
**File:** `Jenkinsfile-27-Multi-Cloud-Deploy`
- Deploy to AWS EKS and GCP GKE
- Multi-cloud strategy
- Kubernetes deployments

### 28. Docker Build, Push & Deploy
**File:** `Jenkinsfile-28-Docker-Build-Push-Deploy`
- Complete Docker workflow
- Build, push to registry, deploy via SSH
- Production deployment pattern
- SSH agent usage

---

## Notifications

### 29. Comprehensive Notifications
**File:** `Jenkinsfile-29-Notifications`
- Email notifications
- Slack integration (now active)
- Teams webhook (now active)
- Generic webhook (now active)
- Success, failure, and always notifications

---

## Infrastructure as Code (IaC)

### 30. Ansible Deployment
**File:** `Jenkinsfile-30-Ansible-Deployment`
- Ansible playbook execution
- Syntax validation and linting
- Dry-run mode (check mode)
- Multi-environment support (dev/staging/production)
- SSH authentication
- Deployment verification
- Parameterized playbook selection

### 31. Kubernetes Deployment
**File:** `Jenkinsfile-31-Kubernetes-Deployment`
- Kubernetes manifest deployment
- Manifest validation
- ConfigMaps and Secrets management
- Dynamic image tag updates
- Dry-run support
- Rolling update with health checks
- Multi-cluster and multi-namespace support
- Deployment verification and status monitoring

### 32. Terraform Deployment
**File:** `Jenkinsfile-32-Terraform-Deployment`
- Infrastructure as Code with Terraform
- Terraform init, validate, and plan
- Terraform apply and destroy
- Multi-environment support (dev/staging/production)
- Auto-approve option with manual approval fallback
- State management
- Outputs archiving

---

## Code Quality & Security

### 33. SonarQube Code Analysis
**File:** `Jenkinsfile-33-SonarQube-Analysis`
- Code quality scanning with SonarQube
- Quality Gate integration
- Support for multiple languages (Java, JavaScript, Python, etc.)
- Branch analysis
- Test coverage integration
- Technical debt tracking

---

## Advanced Kubernetes

### 34. Helm Chart Deployment
**File:** `Jenkinsfile-34-Helm-Deployment`
- Helm 3 chart deployment
- Chart linting and validation
- Install, upgrade, rollback, and uninstall operations
- Multi-environment values files
- Dry-run testing
- Release history tracking
- Atomic deployments

---

## Automation & Utilities

### 35. Cron/Scheduled Builds
**File:** `Jenkinsfile-35-Cron-Scheduled-Build`
- Scheduled builds using cron expressions
- Nightly builds automation
- Automated testing and quality scans
- Database backups
- Cleanup tasks
- Report generation
- Multiple cron schedule examples

### 36. Credentials Usage
**File:** `Jenkinsfile-36-Credentials-Usage`
- Username/Password credentials
- Secret text credentials
- Secret file credentials
- SSH private key usage
- AWS credentials binding
- Docker registry authentication
- Multiple credentials handling
- Security best practices

---

## Quick Reference

### Common Use Cases

| Use Case | Jenkinsfile |
|----------|-------------|
| Learn complete pipeline syntax | `Jenkinsfile-00-Basic_Structure` |
| Need parameters in build | `Jenkinsfile-02-Parameters` |
| Running tests in parallel | `Jenkinsfile-07-Parallel-Tests` |
| Building with Docker | `Jenkinsfile-03-Timestamps-Docker` |
| Deploying to production | `Jenkinsfile-13-Branch-Condition` |
| Handling flaky operations | `Jenkinsfile-15-Retry` |
| Manual approval step | `Jenkinsfile-17-Input-Approval` |
| Email notifications | `Jenkinsfile-29-Notifications` |
| Python project | `Jenkinsfile-22-Python-Venv` |
| Maven project | `Jenkinsfile-12-Tools-Maven` |
| Multi-cloud deployment | `Jenkinsfile-27-Multi-Cloud-Deploy` |
| Security scanning | `Jenkinsfile-26-Docker-Security-Scan` |
| Microservices | `Jenkinsfile-08-Parallel-Microservices` |
| Ansible deployment | `Jenkinsfile-30-Ansible-Deployment` |
| Kubernetes deployment | `Jenkinsfile-31-Kubernetes-Deployment` |
| Terraform IaC | `Jenkinsfile-32-Terraform-Deployment` |
| SonarQube code quality | `Jenkinsfile-33-SonarQube-Analysis` |
| Helm charts | `Jenkinsfile-34-Helm-Deployment` |
| Scheduled/cron jobs | `Jenkinsfile-35-Cron-Scheduled-Build` |
| Using credentials | `Jenkinsfile-36-Credentials-Usage` |

### Pipeline Syntax Patterns

#### Basic Structure
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // your steps here
            }
        }
    }
}
```

#### With Environment Variables
```groovy
pipeline {
    agent any
    environment {
        MY_VAR = 'value'
    }
    stages { ... }
}
```

#### With Parameters
```groovy
pipeline {
    agent any
    parameters {
        string(name: 'PARAM_NAME', defaultValue: 'default', description: 'Description')
    }
    stages { ... }
}
```

#### With Post Actions
```groovy
pipeline {
    agent any
    stages { ... }
    post {
        always { ... }
        success { ... }
        failure { ... }
    }
}
```

---

## 🚀 Getting Started

1. **Choose a Jenkinsfile** that matches your use case
2. **Copy the content** to your repository
3. **Modify** as needed for your project
4. **Create a Jenkins pipeline job** pointing to this file
5. **Run the pipeline**

## 📝 Notes

- All examples are complete and ready to use
- Some examples require specific Jenkins plugins (e.g., Docker, copyArtifacts)
- Credential IDs in examples should be replaced with your actual credentials
- Docker examples require Docker to be installed on Jenkins agents
- Some examples are commented out and need to be configured (e.g., Slack, Teams)

## 🔗 Jenkins Built-in Variables

Access Jenkins environment variables in any pipeline:
- `${env.JOB_NAME}` - Job name
- `${env.BUILD_NUMBER}` - Build number
- `${env.BUILD_URL}` - Build URL
- `${env.WORKSPACE}` - Workspace path
- `${env.BRANCH_NAME}` - Git branch name (for multibranch)
- `${env.NODE_NAME}` - Agent node name

View all available variables: `http://your-jenkins-url/env-vars.html`

---

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Pipeline Steps Reference](https://www.jenkins.io/doc/pipeline/steps/)

---

**Created for Jenkins Zero to Hero - Day 06**  
*Jenkins Basic Pipeline Structure for Daily DevOps Routine*

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
