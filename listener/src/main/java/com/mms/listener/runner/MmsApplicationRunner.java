package com.mms.listener.runner;

import com.mms.listener.service.FileCopyService;
import com.mms.listener.service.FileListenerService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class MmsApplicationRunner implements CommandLineRunner {
    
    private final FileListenerService fileListenerService;
    private final FileCopyService fileCopyService;
    
    public MmsApplicationRunner(FileListenerService fileListenerService, FileCopyService fileCopyService) {
        this.fileListenerService = fileListenerService;
        this.fileCopyService = fileCopyService;
    }
    
    @Override
    public void run(String... args) throws Exception {
        System.out.println("=====================================");
        System.out.println("🚀 MMS Listener Application");
        
        // Parse command line arguments to determine mode
        String mode = parseMode(args);
        
        System.out.println("📋 Operation Mode: " + mode.toUpperCase());
        System.out.println("=====================================");
        
        switch (mode.toLowerCase()) {
            case "listener":
                runListenerMode();
                break;
            case "copy":
                runCopyMode();
                break;
            default:
                printUsage();
                System.exit(1);
        }
    }
    
    private String parseMode(String[] args) {
        for (String arg : args) {
            if (arg.startsWith("--mode=")) {
                return arg.substring(7);
            }
        }
        // Default to listener mode for backward compatibility
        return "listener";
    }
    
    private void printUsage() {
        System.out.println("Usage: java -jar mms-listener.jar --mode=<MODE>");
        System.out.println("");
        System.out.println("Available modes:");
        System.out.println("  listener  - Monitor folders and upload files to MMS backend (removes files after upload)");
        System.out.println("  copy      - Monitor folders and copy files to destination folders (preserves original files)");
        System.out.println("");
        System.out.println("Examples:");
        System.out.println("  java -jar mms-listener.jar --mode=listener");
        System.out.println("  java -jar mms-listener.jar --mode=copy");
    }
    
    private void runListenerMode() {
        try {
            System.out.println("🎧 Starting in LISTENER mode...");
            System.out.println("📁 This mode will monitor configured folders and upload new/modified files to the backend.");
            System.out.println("⚠️  Files will be DELETED after successful upload!");
            fileListenerService.startListening();
        } catch (Exception e) {
            System.err.println("❌ Failed to start listener mode: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
    
    private void runCopyMode() {
        try {
            System.out.println("🗂️ Starting in COPY mode...");
            System.out.println("📁 This mode will monitor source folders and copy files to destination folders.");
            System.out.println("✅ Original files will be PRESERVED in source folders.");
            fileCopyService.startFileCopyService();
        } catch (Exception e) {
            System.err.println("❌ Failed to start copy mode: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
