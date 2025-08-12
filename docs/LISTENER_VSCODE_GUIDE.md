# VS Code Launch Guide for MMS Listener

## Quick Reference

The MMS Listener application now has complete VS Code integration with launch configurations for both operation modes.

## 🚀 Available Launch Configurations

### From MMS Workspace Root

- **MMS Listener - Listener Mode**: Monitor folders and upload files
- **MMS Listener - Backup Mode**: Download all files from backend  
- **MMS Listener - Debug (Listener)**: Debug listener mode with breakpoints
- **MMS Listener - Debug (Backup)**: Debug backup mode with breakpoints

## 📋 How to Run

1. **Open VS Code** in the MMS workspace (`d:\dev\mms`)
2. **Press F5** or go to Run and Debug panel (Ctrl+Shift+D)
3. **Select configuration** from dropdown
4. **Click run** or press F5

## 🛠️ Available Tasks

- **Build MMS Listener**: Compile the application
- **Package MMS Listener**: Create JAR file
- **Run MMS Listener - Listener Mode**: Package and run listener mode
- **Run MMS Listener - Backup Mode**: Package and run backup mode

## ⚙️ Configuration Files

VS Code configurations are located in:
- `/.vscode/launch.json` - Main workspace launch configurations
- `/.vscode/tasks.json` - Build and run tasks
- `/listener/.vscode/` - Local listener project configurations

## 🔧 Prerequisites

1. Install recommended VS Code extensions (Java Extension Pack)
2. Configure `listener/src/main/resources/application.yml`
3. Ensure MMS backend is running
4. Have Java 24 and Maven installed

## 📖 Detailed Guide

See `listener/VSCODE_LAUNCH_GUIDE.md` for comprehensive documentation including:
- Debugging features
- Troubleshooting guide
- Configuration details
- Best practices
