# 🚀 Day 03 — Jenkins Basic Configuration

Welcome to **Day 03**! 

Now that we have our Jenkins Server and Agent running (thanks to Day 01 & 02), it's time to configure the tools and plugins that will power our pipelines.

## 📋 Prerequisites

*   Jenkins Server is up and running.
*   Jenkins Agent (`mgmt`) is connected.
*   You have administrative access to Jenkins.


## 🌐 DNS Pointing

https://pihole.devopsinaction.lab/admin/

| 🏷️ Hostname                 | 🖥️ IP          |
| ---------------------------- | --------------- |
| `jenkins.devopsinaction.lab` | `192.168.1.102` |


## ⚙️ Nginx Proxy Manager Configuration

https://npm.devopsinaction.lab


| 🌍 Domain                                                          | 🖥️ IP          | 🔌 Port | 🔐 SSL | 🚦 Force SSL |
| ------------------------------------------------------------------ | --------------- | ------- | ------ | ------------ |
| `jenkins.devopsinaction.lab` | `192.168.1.102` | `8080`  | ✅ Yes  | ✅ Yes        |


Access jenkins with:
[https://jenkins.devopsinaction.lab/](https://jenkins.devopsinaction.lab/)


## 🛠️ Global Tool Configuration

We need to tell Jenkins where to find the tools it needs to build our projects. Go to **Dashboard** > **Manage Jenkins** > **Tools**.

### 1. ☕ JDK (Java Development Kit)

Since we are running in containers, we can often rely on the pre-installed JDK or have Jenkins install it automatically.

1.  Scroll to **JDK**.
2.  Click **Add JDK**.
3.  **Name:** `jdk17` (or your preferred version).
4.  **Install automatically:** Checked.
5.  **Version:** Select `jdk-17` from the list (requires an Oracle account) or use **Adoptium** installer if available.
    *   *Alternative:* If you mounted a JDK volume or know the path in the container, uncheck "Install automatically" and provide the **JAVA_HOME** path (e.g., `/opt/java/openjdk`).

### 2. 🐙 Git

Jenkins needs Git to pull your source code.

1.  Scroll to **Git**.
2.  **Name:** `Default`
3.  **Path to Git executable:** `/usr/bin/git`
    *   *Note:* This is the standard path in most Linux containers (including the official Jenkins image). If you are on Windows (without Docker), it might be `C:\Program Files\Git\bin\git.exe`.

### 3. 📦 Maven

Maven is essential for building Java projects.

1.  Scroll to **Maven**.
2.  Click **Add Maven**.
3.  **Name:** `maven3`
4.  **Install automatically:** Checked.
5.  **Version:** Select the latest version (e.g., `3.9.x`).

### 4. 🐘 Gradle

Gradle is another popular build tool for Java projects.

1.  Scroll to **Gradle**.
2.  Click **Add Gradle**.
3.  **Name:** `gradle`
4.  **Install automatically:** Checked.
5.  **Version:** Select a recent version (e.g., `8.x`).

Click **Save** at the bottom of the page.

Note: If you are using a different version of Java, you may need to install it manually or use a different version of the JDK.

### ✨ Additional Notes

* 🤖 We can use **agent-wise tools**, depending on what each agent needs.
* 🛠️ It’s possible to **configure the setup directly on the agent itself**.
* 🎨 Make everything **clear, organized, and nicely presented**!

This will cover in "Day 04 — Jenkins Agent Tools Setup on Agent (Local) using Docker Compose"


### 5. 🧩 Plugin Management

Plugins extend Jenkins functionality. Let's ensure we have some basics.

1.  Go to **Manage Jenkins** > **Plugins**.
2.  Click on **Available plugins**.
3.  Search for and install these recommended plugins if you don't have them:
    * **Rebuilder**: Allows you to rebuild a job with the same parameters.
    * **Safe Restart**: Adds a link to safely restart Jenkins.
    * **Pipeline**: The core plugin for pipelines (usually installed by default).
    * **Docker Pipeline**: For using Docker in pipelines.
    * **Publish over SSH**: For remote file operations.
    * **SSH Remote Hosts**: For remote file operations.
    * **SSH Agent** / **SSH Agent Plugin**: For remote file operations.
    * **Build Pipeline View**: For remote file operations.
    * **Text File Operations**: For remote file operations.
    * **ThinBackup** / **ThinBackup Plugin**: For backup operations.
    * **Build History Metrics**: For remote file operations.
    * **Build Pipeline** / **Build Pipelines Plugin**: For remote file operations.
    * **Multijob**: For remote file operations.
    * **Docker Build Step Plugin**: For remote file operations.
    * **Jenkins Disk-usage Plugin**: For remote file operations.
    * **Performance Publisher Plugin**: For remote file operations.
    * **Performance Plugin**: For remote file operations.
    * **cloudbees-folder**: For folder-based job organization.
    * **simple-theme-plugin**: For UI theming.
    * **Octopus Deploy**: For deployment integrations.
    * **Pipeline Timeline**: For pipeline timeline visualization.
    * **Nested View**: For nested job views.
    * **CloudBees Docker Build and Publish**: For Docker build/publish operations.
    * **GitLab**: GitLab integration.
    * **GitLab Branch Source Plugin**: For remote file operations.
    * **GitLab API Plugin**: For remote file operations.
    * **GitLab Hook Plugin**: For remote file operations.
    * **GitLab Merge Request Plugin**: For remote file operations.
    * **Generic Webhook Trigger**: For remote file operations.
    * **Priority Sorter**: For remote file operations.
    * **GitLab Authentication**: Authentication with GitLab.
    * **Pipeline** (already listed; retained above).
    * **Pipeline Timeline** (already listed; retained above).
    * **SSH Build Agents**: For building on SSH-connected agents.
    * **Dashboard View**: For dashboard-style job views.
    * **Docker API Plugin**: For Docker API integrations.
    * **Role-based Authorization Strategy**: For RBAC in Jenkins.
    * **SSH Credentials Plugin**: For SSH credentials management.
    * **Google Chat Notification Plugin**: For Google Chat notifications.

4.  Select **Install without restart** (unless a restart is strictly required).


### 6. ⚙️ Jenkins System Configuration

#### **Manage Jenkins → System**

Configure the following settings:

* **Jenkins URL:**
  *(Set your server URL, e.g., `https://jenkins.devopsinaction.lab/`)*

* **System Admin E-mail Address:**
  *(Used for notifications and system alerts)*

* **Usage Statistics:**
  *(Enable/disable Jenkins usage reporting)*

* **E-mail Notification:**

  * Default Content Type: **HTML**

### 7. 🔐 Configure Global Security

#### **Manage Jenkins → Configure Global Security**

* **Markup Formatter:**
  Set to **Safe HTML**
  Click **Save**.

### 8. 🏠 Customize Jenkins Dashboard

#### **Jenkins → Dashboard → Add Description**

Add the following HTML to display a styled header:

```html
<h1 style="color:black;background-color:DodgerBlue;text-align:center;">
    Welcome to DevOps in Action Jenkins "Zero to Hero Series"
</h1>
```

### 9. 🏠 Customize Jenkins Job Description
Select job > configure

Add the following HTML to display a styled header:

```html
<b>Demo Environment</b> <br>
<b>Git: </b> https://github.com/meibraransari/Jenkins-Zero-To-Hero.git <br>
<b>Branch: </b> Main <br>
<b>Domain: </b> NA <br>
```

### 10. 🧪 Verify Setup with a Test Job

Let's create a simple job to verify that our Agent (`mgmt`) is working and can execute commands.

stage view pipeline
```
pipeline {  
    agent any  
    stages {  
            stage ('Build') {  
				steps {
					echo 'Building the application....'
				}
            }  
            stage ('Test') {  
				steps {
					echo 'Testing the application....'
				}  
            }   
            stage ('Deploy') {  
				steps {
					echo 'Deploying the application....'
				}  
            }  
            stage ('Monitor') {  
				steps {
					echo 'Monitoring the application....'
				}  
            }  
    } 
	post {
        always {
            echo 'application....'
        }

        success {
            echo 'application....'
        }

        failure {
            echo 'application....'
        }
    } 
}
```

System information pipeline
```
pipeline {
    agent any
    
    stages {
        stage('Collect System Information') {
            steps {
                sh '''
                    #!/bin/bash
                    # Script to collect system information

                    # Hostname
                    echo "Hostname: $(hostname)"

                    # Kernel Version
                    echo "Kernel Version: $(uname -r)"

                    # Operating System
                    echo "Operating System: $(lsb_release -ds || cat /etc/*release || uname -om)"

                    # CPU Information
                    echo "CPU Information:"
                    lscpu

                    # Memory Information
                    echo "Memory Information:"
                    free -h

                    # Disk Space
                    echo "Disk Space:"
                    df -h

                    # Installed Packages
                    echo "Installed Packages:"
                    dpkg -l || rpm -qa
                '''
            }
        }
    }
}

```

If you see **SUCCESS**, congratulations! Your Jenkins setup is correctly configured and communicating with the Agent. 🚀


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
