package com.mms.listener.runner;

import com.mms.listener.service.FileListenerService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class MmsApplicationRunner implements CommandLineRunner {
    
    private final FileListenerService fileListenerService;
    
    public MmsApplicationRunner(FileListenerService fileListenerService) {
        this.fileListenerService = fileListenerService;
    }
    
    @Override
    public void run(String... args) throws Exception {
        System.out.println("=====================================");
        System.out.println("🚀 MMS Listener Application");
        System.out.println("📋 Operation Mode: LISTENER");
        System.out.println("=====================================");
        
        runListenerMode();
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
}
