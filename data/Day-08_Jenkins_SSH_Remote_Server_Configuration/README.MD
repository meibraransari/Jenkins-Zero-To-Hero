# 🚀 Day 08 — Jenkins SSH Remote Server Configuration 🔐

> **Professional guide for securely configuring SSH connections from Jenkins to remote servers**

## 📋 Table of Contents

- [Overview](#-overview)
- [Best Practice: Jenkins Credentials Store](#-best-practice-jenkins-credentials-store)
- [Alternative: Volume Mount Approach](#-alternative-volume-mount-approach)
- [Recommended Approach](#-recommended-approach)

---

## 🎯 Overview

To enable Jenkins to connect to remote servers via SSH, you need to store the SSH private key securely in Jenkins. This guide provides best practices and implementation steps for secure SSH authentication.

---

## ✨ Best Practice: Jenkins Credentials Store

### 🔑 Step 1: Generate SSH Key Pair

Generate your SSH key file anywhere - the location doesn't matter as it will be stored in Jenkins credentials. You can also use an existing `ssh_keys` file from your Jenkins setup directory.


```bash
ssh-keygen -t rsa -b 4096 -C "jenkins@devopsinaction.lab" -f jenkins_key
```

---

### 🌐 Step 2: Configure Remote Server

#### Enable SSH Public Key Authentication

First, verify and enable `PubkeyAuthentication` on your remote server:

```bash
# Check current PubkeyAuthentication setting
grep -iE "PubkeyAuthentication" /etc/ssh/sshd_config

# OR use this alternative
sshd -T | grep pubkeyauthentication
```

#### Allow Public Key Authentication (Server Side - Destination)

```bash
# Enable PubkeyAuthentication
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config

# Enable root login (if needed)
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Restart SSH service
service ssh restart
service ssh status
```

---

### 📤 Step 3: Deploy Public Key to Remote Server

#### Option A: Using ssh-copy-id (Recommended)

```bash
# Copy public key to remote server's authorized_keys
ssh-copy-id -i jenkins_key.pub user@192.168.1.210
```

#### Option B: Manual Deployment

**For root user:**

```bash
# Add Jenkins public key to root's authorized_keys
echo '
# This is new jenkins key for jenkins server 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVLkaDwY/efVgAUcWeRzIctvB5sOBLeyM3SRp2rx3QNmZvZwmJ1Q3yo8EOQDXhBUcLFMX1TyR1H1SGL6D0m+bfrY883oLhV3L1jlAvQFTFZfllK+lSsTGPa3zSvmXVJvf5kMSzNPlf2DcHIWqHEl+mBMj9J0WsI7BpYkS0sZ7lVEoFUPPqt1nK47+f7Vf9ZoQQ2N9ITrNRKYz5uYhqco/Lceszojsh9kEutKFRSmjbIFeq7No1CqLtu8xZ0NOrGORYjaS/euLnETw28TEwh0jMI4X81SAkmsEeorfUWNpl9XTkC+JZ3Y+jIhTQKy03e8W/wKWQFyu7NkhJlTK2fW0vLcS3DbmzlL7awqH5AxH02NnYdUEQwPO8k/HyDJtER/vwwDtx6jjFGx9SsowOKPEI0apWkTNEVNn52k93II13nZZ0uMND6uYPMjWxRYu5jDBhDVVwN4Uvf+LIzUbCIcAJGz3XsjZFTg91QOCIAit6A5WBegj6cubk9OI5ufDf3hkdN/YjImfD7yWs3Er0zstrpDpD3pC5UgUmNXzLaRcRMPNiRZ3USRwNS+XebgoOoutJyj3fOSxuXbHn4m2DfZyJX5lwYpzAE2mMPm0OEgPlXPmXo6fOL2gqy+U0sV8JAWCr+CCQCEEIuIDhX3DtcToeMDFsnQTbaQEx2hsni/f97Q== jenkins_id_rsa_key' >> /root/.ssh/authorized_keys

# Verify the key was added
cat /root/.ssh/authorized_keys
```

**For normal user:**

```bash
# Add Jenkins public key to user's authorized_keys
echo '
# This is new jenkins key for jenkins server 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVLkaDwY/efVgAUcWeRzIctvB5sOBLeyM3SRp2rx3QNmZvZwmJ1Q3yo8EOQDXhBUcLFMX1TyR1H1SGL6D0m+bfrY883oLhV3L1jlAvQFTFZfllK+lSsTGPa3zSvmXVJvf5kMSzNPlf2DcHIWqHEl+mBMj9J0WsI7BpYkS0sZ7lVEoFUPPqt1nK47+f7Vf9ZoQQ2N9ITrNRKYz5uYhqco/Lceszojsh9kEutKFRSmjbIFeq7No1CqLtu8xZ0NOrGORYjaS/euLnETw28TEwh0jMI4X81SAkmsEeorfUWNpl9XTkC+JZ3Y+jIhTQKy03e8W/wKWQFyu7NkhJlTK2fW0vLcS3DbmzlL7awqH5AxH02NnYdUEQwPO8k/HyDJtER/vwwDtx6jjFGx9SsowOKPEI0apWkTNEVNn52k93II13nZZ0uMND6uYPMjWxRYu5jDBhDVVwN4Uvf+LIzUbCIcAJGz3XsjZFTg91QOCIAit6A5WBegj6cubk9OI5ufDf3hkdN/YjImfD7yWs3Er0zstrpDpD3pC5UgUmNXzLaRcRMPNiRZ3USRwNS+XebgoOoutJyj3fOSxuXbHn4m2DfZyJX5lwYpzAE2mMPm0OEgPlXPmXo6fOL2gqy+U0sV8JAWCr+CCQCEEIuIDhX3DtcToeMDFsnQTbaQEx2hsni/f97Q== jenkins_id_rsa_key' >> /home/$(whoami)/.ssh/authorized_keys

# Verify the key was added
cat /home/$(whoami)/.ssh/authorized_keys
```

#### 🔧 Troubleshooting: SSH Directory Missing

If you encounter "No such file or directory" error:

```bash
# Create .ssh directory with proper permissions
mkdir -p /home/$(whoami)/.ssh/
chmod 700 /home/$(whoami)/.ssh/
chown -R $(whoami):$(whoami) /home/$(whoami)/.ssh
```

---

### 🔐 Step 4: Add Private Key to Jenkins

1. **Navigate to Jenkins Credentials**:
   ```
   Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials → Add Credentials
   ```

2. **Configure Credential**:
   - **Kind**: `SSH Username with private key`
   - **ID**: `ssh-remote-server` (use a memorable identifier)
   - **Username**: `remote-user`
   - **Private Key**: Paste your private key content or upload the file
   - **Passphrase**: Enter passphrase if your key has one

---

### 🚀 Step 5: Use in Jenkins Pipeline

📦 **Install SSH Agent Plugin**
Install the **SSH Agent Plugin** from the Jenkins plugin manager if not already installed:


> In Jenkins UI:
> 1. Navigate to: `Manage Jenkins` → `Manage Plugins` → `Available`
> 2. Search for: `SSH Agent`
> 3. Click `Install` → `Restart Jenkins`


**Create new job to test it**
```groovy
pipeline {
    // agent any
    agent { label 'sg' }
    stages {
        stage('SSH to Remote Server') {
            steps {
                sshagent(['ssh-remote-server']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no user@192.168.1.210 'pwd && hostname -I'
                    '''
                }
            }
        }
    }
}
```

---

## 📦 Alternative: Volume Mount Approach (Not Recommended)

> [!WARNING]
> This method is less secure than using Jenkins Credentials Store. Use only if absolutely necessary.

### Docker Compose Configuration

```yaml
services: 
  jenkins: 
    image: jenkins/jenkins:latest 
    container_name: jenkins 
    privileged: true 
    user: root 
    restart: always 
    ports: 
      - 8080:8080 
    volumes: 
      - ${JENKINS_DATA_DIR}:/var/jenkins_home 
      - /var/run/docker.sock:/var/run/docker.sock
      - ${SSH_KEY_PATH}:/var/jenkins_home/.ssh/id_rsa:ro  # Mount SSH key
      - ${SSH_KNOWN_HOSTS}:/var/jenkins_home/.ssh/known_hosts:ro  # Optional
    environment: 
      - DOCKER_HOST=unix:///var/run/docker.sock 
      - TZ=UTC 
    healthcheck: 
      test: ["CMD-SHELL", "curl -f http://localhost:8080/login || exit 1"] 
      interval: 30s 
      timeout: 10s 
      retries: 5
```

### Set Proper Permissions

Execute in a startup script or entrypoint:

```bash
chmod 600 /var/jenkins_home/.ssh/id_rsa
chown jenkins:jenkins /var/jenkins_home/.ssh/id_rsa
```

---

## 🏆 Recommended Approach

> [!IMPORTANT]
> **Use Jenkins Credentials Store with SSH Agent Plugin** for production environments.

### Why Jenkins Credentials + SSH Agent Plugin?

The **Jenkins Credentials Store with SSH Agent Plugin** is the **best practice** because:

- ✅ **Encrypted Storage**: Keys are encrypted at rest
- ✅ **Access Control & Auditing**: Fine-grained permissions and audit trails
- ✅ **No File Permission Issues**: Eliminates common file permission problems
- ✅ **Multi-Agent Support**: Works seamlessly across different Jenkins agents
- ✅ **Easy Management**: Simple rotation and credential management
- ✅ **Security Best Practice**: Industry-standard approach



---

## 🧠 About This Project

**Made with ❤️ for DevOps Engineers** Powered by **DevOps In Action**, this repository offers **real-world, hands-on DevOps setups** for CI/CD pipelines, containerization, Kubernetes, cloud platforms (AWS, GCP, Azure), and infrastructure at scale.

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
