package com.mms.listener.runner;

import com.mms.listener.service.BackupService;
import com.mms.listener.service.FileListenerService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class MmsApplicationRunner implements CommandLineRunner {
    
    private final FileListenerService fileListenerService;
    private final BackupService backupService;
    
    public MmsApplicationRunner(FileListenerService fileListenerService, BackupService backupService) {
        this.fileListenerService = fileListenerService;
        this.backupService = backupService;
    }
    
    @Override
    public void run(String... args) throws Exception {
        // Parse command line arguments for mode
        String mode = "listener"; // default mode
        
        for (String arg : args) {
            if (arg.startsWith("--mode=")) {
                mode = arg.substring(7);
                break;
            }
        }
        
        System.out.println("=====================================");
        System.out.println("🚀 MMS Listener Application");
        System.out.println("📋 Operation Mode: " + mode.toUpperCase());
        System.out.println("=====================================");
        
        switch (mode.toLowerCase()) {
            case "listener":
                runListenerMode();
                break;
            case "backup":
                runBackupMode();
                break;
            default:
                System.err.println("❌ Invalid operation mode: " + mode);
                System.err.println("💡 Valid modes are: 'listener' or 'backup'");
                System.err.println("💡 Usage: java -jar mms-listener.jar --mode=listener");
                System.err.println("💡    or: java -jar mms-listener.jar --mode=backup");
                System.exit(1);
        }
    }
    
    private void runListenerMode() {
        try {
            System.out.println("🎧 Starting in LISTENER mode...");
            System.out.println("📁 This mode will monitor configured folders and upload new/modified files to the backend.");
            fileListenerService.startListening();
        } catch (Exception e) {
            System.err.println("❌ Failed to start listener mode: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
    
    private void runBackupMode() {
        try {
            System.out.println("💾 Starting in BACKUP mode...");
            System.out.println("⬇️ This mode will download all files from the backend and save them locally.");
            backupService.startBackup();
            
            // In backup mode, we can exit after the backup is complete
            // The backup service handles the async operations
            System.out.println("🔄 Backup process initiated. Check console for progress...");
            
            // Keep the application running for a reasonable time to complete downloads
            Thread.sleep(60000); // Wait 1 minute for downloads to start
            
        } catch (Exception e) {
            System.err.println("❌ Failed to start backup mode: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
