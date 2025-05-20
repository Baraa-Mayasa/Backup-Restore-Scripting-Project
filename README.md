# 🔄 Automated Backup & Restore Solution

This project is my initiative to build an **automated backup and restore solution** for critical data across different operating systems, but focusing on linux. The goal was to enhance **data safety** and **streamline recovery** processes.

A key objective was to **implement the same core logic** using platform-specific tools and scripting languages tailored for **Linux and Windows** environments.

---

## 🚀 Features

- **Automated Daily Backups**: Regular backups of specified directories to local storage.
- **Cloud Integration**: Upload backups to **Google Drive** using `rclone` for off-site protection.
- **Automated Restoration**: Restore from the **latest** or a **specified** backup with a single command.
- **Multi-Platform Support**: Implemented for:
  - Linux using **Bash & Cron**
  - Windows using **PowerShell & Task Scheduler**
- **Logging**: Tracks all backup and restore operations for auditability.

---

## 🛠️ Technologies Used

### Linux Implementation

- `Bash`: For scripting the backup and restore logic  
- `tar`: Used for archiving and compressing files  
- `rclone`: For secure cloud uploads to Google Drive  
- `cron`: To schedule daily backups  

### Windows Implementation

- `PowerShell`: For scripting backup and restore logic  
- `Compress-Archive` / `Expand-Archive`: PowerShell cmdlets for ZIP operations  
- `Task Scheduler`: For running scripts automatically on schedule  

---

## 💡 Key Learnings & Experience Gained

This project gave me hands-on experience with:

- **Shell Scripting**: Developed my skills in automation using Bash and PowerShell.
- **System Scheduling**: Gained practical knowledge of cron jobs and Task Scheduler.
- **Cloud Storage Integration**: Learned to configure and utilize `rclone` effectively.
- **Error Handling & Logging**: Implemented robust logging for system monitoring.
- **Cross-OS Adaptation**: Adapted a core idea to different operating systems using native tools.
- **Real-World Problem Solving**: Debugged and optimized scripts for practical usage scenarios.

---

## 📂 Project Structure

```
.
├── linux/
│   ├── yedekle.sh            # Linux backup script
│   └── geri_yukle.sh         # Linux restore script
├── windows/
│   ├── backup.ps1            # Windows backup script
│   └── restore.ps1           # Windows restore script
└── README.md                 # This README file
```

---

## 📝 Setup & Usage

Refer to the comments and instructions inside each script file for details on:

- What to configure  
- How to run the scripts  

---

## 🤝 Contributing

Feel free to **fork** this repository, **explore the code**, and open issues or pull requests if you have suggestions or improvements!
