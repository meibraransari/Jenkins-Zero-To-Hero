# 🚀 Day 18 — Jenkins Job Backup & Restore

## 📋 Overview
Interactive shell script to backup and restore Jenkins job configurations (`config.xml` files).

---

## ✨ Features
- 💾 **Backup**: Create timestamped backups of all Jenkins job configs
- ♻️ **Restore**: Restore from the latest backup automatically
- 📁 **Organized Storage**: Timestamped backup directories
- 🌲 **Tree View**: Visual representation of backup structure
- 🎯 **Interactive Menu**: User-friendly command-line interface

---

## 🎬 Video Demonstration

[![Watch on Youtube](https://i.ytimg.com/vi/-uo5pTo8Fuo/maxresdefault.jpg)](https://youtu.be/-uo5pTo8Fuo)

## 🛠️ Installation

### Step 1: Copy Script
```bash
sudo cp jenkins_job_manager /usr/bin/
```

### Step 2: Make Executable
```bash
sudo chmod 755 /usr/bin/jenkins_job_manager
```

---

## 🚀 Usage

### Launch the Tool
```bash
jenkins_job_manager
```

### Menu Options
```
======================================
🛠 Jenkins Job Config Backup & Restore
======================================
1. Take backup (job config.xml)
2. Restore latest backup
x. Exit
======================================
Enter your choice:
```

- **Option 1**: Creates backup in `/HDD2TB/iansari/jenkins/jenkins_job_backup/<timestamp>/`
- **Option 2**: Restores from the latest backup folder
- **Option x**: Exit the tool

---

## 📂 Directory Structure

### Before Backup
```
/HDD2TB/iansari/jenkins/
├── jenkins_data/
│   └── jobs/
│       ├── Job-1/
│       │   └── config.xml
│       └── Job-2/
│           └── config.xml
```

### After Backup
```
/HDD2TB/iansari/jenkins/
├── jenkins_data/
│   └── jobs/...
└── jenkins_job_backup/
    └── 15-Jan-2026_12-30-45/
        ├── Job-1/
        │   └── config.xml
        └── Job-2/
            └── config.xml
```

---

## ⚙️ Configuration

Update these variables in the script if needed:

```bash
JENKINS_BASE="/HDD2TB/iansari/jenkins"        # Jenkins base directory
JOBS_DIR="$JENKINS_BASE/jenkins_data/jobs"     # Jenkins jobs directory
BACKUP_BASE="$JENKINS_BASE/jenkins_job_backup" # Backup storage location
```

---

## ⚠️ Important Notes

### Restart Required
After restoring jobs, restart Jenkins:
```bash
docker restart jenkins
# OR
sudo systemctl restart jenkins
```

### Prerequisites
- ✅ Tree command installed (`sudo apt install tree`)
- ✅ Read/write access to Jenkins directories
- ✅ Sufficient disk space for backups

---

## 📸 Example Output

### Backup
```
💾 Starting Jenkins job config backup...
✅ Backed up: Job-1
✅ Backed up: Job-2
✅ Backed up: Job-3
=================================
✅ Backup completed!
📁 Backup location: /HDD2TB/iansari/jenkins/jenkins_job_backup/15-Jan-2026_12-30-45
=================================
```

### Restore
```
♻️ Restoring Jenkins job configs from:
📁 /HDD2TB/iansari/jenkins/jenkins_job_backup/15-Jan-2026_12-30-45
---------------------------------
✅ Restored: Job-1
✅ Restored: Job-2
✅ Restored: Job-3
=================================
✅ Restore completed!
⚠️ Restart Jenkins if required
=================================
```

---

## 🔄 Workflow

1. **Backup** 💾
   - Select option `1`
   - Script creates timestamped folder
   - Copies all `config.xml` files
   - Displays tree structure

2. **Restore** ♻️
   - Select option `2`
   - Script finds latest backup
   - Restores all job configs
   - Reminder to restart Jenkins

3. **Exit** 👋
   - Press `x` to exit

---

## 🎯 Use Cases

- 🔧 **Pre-upgrade backups**
- 🚀 **Disaster recovery**
- 📦 **Job migration between Jenkins instances**
- 🔄 **Version control for job configurations**
- 🧪 **Testing configuration changes safely**

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| ⚠️ No backups found | Create a backup first (option 1) |
| ⚠️ Permission denied | Run with sudo or fix directory permissions |
| ⚠️ Jobs not visible after restore | Restart Jenkins container/service |
| ⚠️ Tree command not found | Install tree: `sudo apt install tree` |

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
