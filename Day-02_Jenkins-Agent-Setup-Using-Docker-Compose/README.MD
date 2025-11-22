# 🚀 Day 02 — Jenkins Agent Setup Using Docker Compose

Welcome to **Day 02** of the DevOps Jenkins series!
This guide will help you set up a Jenkins Agent using Docker Compose.

## 📋 Prerequisites

Ensure you have Docker and Docker Compose installed on your machine.

## 🚀 Deployment Steps

Follow these steps to deploy the Jenkins Agent:

1.  **Navigate to the directory:**
    ```bash
    cd /HDD2TB/iansari/jenkins
    ```

2.  **Set Compose file:**
    ```yaml   
    services:
    # Run another agent on another pc/server (conenct using jenkins@ip:2020)
    agent:
        image: jenkins/ssh-agent:jdk21
        container_name: jenkins_agent
        restart: always
        privileged: false
        #user: jenkins
        user: root
        ports:
        - "2020:22"
        environment:
        - DOCKER_HOST=unix:///var/run/docker.sock
        - TZ=UTC
        volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /usr/bin/docker:/usr/bin/docker                         # Optional, some systems need this
        - ./JENKINS_AGENT_DATA_DIR/agent_dind_data:/var/lib/docker      # Persistent Docker storage volume
        - ./JENKINS_AGENT_DATA_DIR/workspace:/home/jenkins/workspace    # Workspace Directory
        - ./JENKINS_AGENT_DATA_DIR/tools:/tools                         # Tools Directory if required
        - /usr/bin/git:/usr/bin/git                               # Point additional tools
        healthcheck:
        test: ["CMD-SHELL", "nc -z localhost 22 || exit 1"]
        interval: 30s
        timeout: 5s
        retries: 5
        deploy:
        resources:
            limits:
            cpus: '1.0'
            memory: 1g
    ```

    Start the container to create the required volume mounts, then immediately bring it down to fix permissions.
    ```bash
    docker compose up -d
    docker compose down
    ```

3.  **Fix Permissions:**
    The agent starts in root mode but operates with the `jenkins` user internally. We need to ensure the data directory has the correct permissions.
    ```bash
    sudo chown -R ubuntu:ubuntu /HDD2TB/iansari/jenkins/JENKINS_DATA_DIR
    ```
    *(Note: Adjust `ubuntu:ubuntu` if your host user is different)*

4.  **Start the Agent:**
    ```bash
    docker compose up -d
    ```

## ⚙️ Jenkins Configuration

Once the agent container is running, configure it in the Jenkins Dashboard.

### 🔐 Add Credentials

1.  Go to **Manage Jenkins** > **Credentials**.
2.  Add a new credential of type **SSH Username with private key**.
3.  **Username:** `jenkins`
4.  **Private Key:** Enter directly. Copy the content of the `jenkins_agent_key` file you generated earlier and paste it here.

### 🖥️ Agent Node Setup

1.  Go to **Manage Jenkins** > **Nodes** > **New Node**.
2.  **Name:** `mgmt`
3.  Select **Permanent Agent**.
4.  Configure as follows:
    *   **Number of executors:** `1`
    *   **Remote root directory:** `/home/jenkins`
    *   **Labels:** `mgmt`
    *   **Launch method:** `Launch agent via SSH`
        *   **Host:** `172.31.4.10` (Replace with your Agent's Private IP)
        *   **Credentials:** Select the credentials created above.
        *   **Host Key Verification Strategy:** `Non verifying Verification Strategy` (or appropriate strategy)
        *   **Port:** `2020` (Check `compose.yaml` if changed)


## 🧠 About This Project

This project is maintained by **DevOps In Action**, mainly focusing on practical, hands-on DevOps setups for CI/CD automation, containerization, and infrastructure management.

### 💼 Connect with Me 👇😊

* 🔥 [**YouTube**](https://www.youtube.com/@DevOpsinAction?sub_confirmation=1)
* ✍️ [**Blog**](https://ibraransari.blogspot.com/)
* 💼 [**LinkedIn**](https://www.linkedin.com/in/ansariibrar/)
* 👨‍💻 [**GitHub**](https://github.com/meibraransari?tab=repositories)
* 💬 [**Telegram**](https://t.me/DevOpsinActionTelegram)
* 🐳 [**Docker Hub**](https://hub.docker.com/u/ibraransaridocker)


### ⭐ If You Found This Helpful...

***Please star the repo and share it! Thanks a lot!*** 🌟






