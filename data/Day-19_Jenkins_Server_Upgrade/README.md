# 🚀 Day 19 — Jenkins Server Upgrade

## 📖 Overview

Upgrading your Jenkins server is a critical maintenance task that ensures you have the latest features, security patches, and bug fixes. This guide demonstrates the proper way to upgrade a Dockerized Jenkins instance while minimizing downtime and avoiding compatibility issues.

---

## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/9I3D_nUY_Ls/maxresdefault.jpg)](https://youtu.be/9I3D_nUY_Ls)


## 🐳 Docker Compose Reference

Below is a typical Jenkins Docker Compose configuration. This serves as a reference for understanding the deployment structure:

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
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
      - TZ=UTC
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/login || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
```

---

## 🎯 Version Strategy

### ✅ Best Practice: Use LTS and Pin Versions

Instead of using `latest`, which can lead to unexpected behavior, always use Long-Term Support (LTS) versions or pin to specific versions for production environments.

**Official Jenkins Images:** https://hub.docker.com/r/jenkins/jenkins/tags

**Recommended image configurations:**

```yaml
# LTS version (recommended for production)
image: jenkins/jenkins:lts

# Pinned to specific LTS version (best for stability)
image: jenkins/jenkins:2.440.1-lts

# LTS with specific JDK version
image: jenkins/jenkins:lts-jdk17
```

**Why pin versions?**
- **Predictability:** Know exactly what version is running
- **Stability:** Avoid unexpected breaking changes
- **Compliance:** Meet audit and regulatory requirements
- **Rollback:** Easy to revert to previous versions if issues arise

---

## 💾 Backup Before Upgrade

### ✅ Mandatory: Always Backup Jenkins Data

**NEVER** perform an upgrade without backing up your Jenkins home directory first. This is your safety net in case something goes wrong.

**Backup procedure:**

```bash
# Stop Jenkins container
docker stop jenkins

# Create timestamped backup of Jenkins data
tar -czvf jenkins_backup_$(date +%F).tar.gz -C ./jenkins_data .
#or simple cp command
cp -r ./jenkins_data ./jenkins_backup_$(date +%F)

# Restart Jenkins
docker start jenkins
```

**What gets backed up:**
- All job configurations
- Build history
- Plugin data
- User credentials and settings
- System configuration

**💡 Pro Tip:** Store backups in a separate location (cloud storage, NAS, etc.) for disaster recovery.

---

## 🔄 Upgrade Procedure

### Step 1: Update Image Version

Modify your `docker-compose.yml` file to use the desired version:

```yaml
services:
  jenkins:
    image: jenkins/jenkins:2.546-jdk25  # or your pinned version
```

### Step 2: Pull New Image

Download the updated Jenkins image:

```bash
docker compose pull jenkins
```

### Step 3: Recreate Container

Apply the changes and recreate the Jenkins container:

```bash
docker compose up -d
```

This command will:
- Stop the old container
- Remove it
- Create a new container with the updated image
- Preserve all data in `/var/jenkins_home` (mounted volume)

### Step 4: Monitor Upgrade

Watch the container logs to ensure Jenkins starts successfully:

```bash
docker logs -f jenkins
```

**What to look for:**
- ✅ "Jenkins is fully up and running"
- ✅ No critical errors
- ⚠️ Any plugin compatibility warnings

---

## 🔌 Plugin Compatibility

### ⚠️ VERY IMPORTANT: Handle Plugins Carefully

Major Jenkins version upgrades may introduce breaking changes in plugin APIs. Rushing to update all plugins immediately can cause instability.

### Recommended Plugin Update Strategy

**After successful login to upgraded Jenkins:**

1. Navigate to **Manage Jenkins** → **Plugin Manager**

2. **Review available updates** before applying them

3. **Update plugins gradually** in batches:
   - Start with critical plugins (Git, Pipeline, Credentials)
   - Test functionality after each batch
   - Monitor for errors or warnings

4. **Avoid "Update All"** immediately after major upgrades
   - Some plugins may not be compatible yet
   - Batch updates allow you to isolate problematic plugins

### 📋 Best Practice Workflow

```
1️⃣ Upgrade Jenkins core
      ↓
2️⃣ Restart Jenkins
      ↓
3️⃣ Verify Jenkins starts successfully
      ↓
4️⃣ Update plugins in batches (5-10 at a time)
      ↓
5️⃣ Restart after each batch
      ↓
6️⃣ Test jobs and pipelines
      ↓
7️⃣ Repeat until all plugins are updated
```

---

## ⚠️ Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Jenkins won't start after upgrade | Restore from backup and check logs for incompatible plugins |
| Plugins showing errors | Downgrade problematic plugin or wait for compatible version |
| Jobs failing unexpectedly | Check plugin changelogs for breaking changes |
| Performance degradation | Review new JVM options or increase container resources |

### Emergency Rollback

If the upgrade fails, you can quickly rollback:

```bash
# Stop current container
docker stop jenkins

# Restore backup
tar -xzvf jenkins_backup_YYYY-MM-DD.tar.gz -C ./jenkins_data

# Revert docker-compose.yml to previous image version
# Then restart
docker compose up -d
```

---

## 🎯 Summary

Upgrading Jenkins requires careful planning and execution:

✅ **Always backup** before starting  
✅ **Use LTS versions** for stability  
✅ **Pin specific versions** for production  
✅ **Upgrade gradually** - core first, then plugins in batches  
✅ **Monitor logs** throughout the process  
✅ **Test thoroughly** before declaring success  

By following these best practices, you can ensure smooth Jenkins upgrades with minimal risk and downtime.


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
