package com.mms.listener.service;

import com.mms.listener.config.MmsConfig;
import io.methvin.watcher.DirectoryWatcher;
import org.springframework.stereotype.Service;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.CompletableFuture;
import java.util.regex.Pattern;

@Service
public class FileListenerService {
    
    private final MmsConfig config;
    private final MmsApiService apiService;
    private DirectoryWatcher watcher;
    private Pattern includePattern;
    private Pattern excludePattern;
    
    public FileListenerService(MmsConfig config, MmsApiService apiService) {
        this.config = config;
        this.apiService = apiService;
        
        // Compile regex patterns for file filtering
        if (config.getFilePatterns().getInclude() != null) {
            this.includePattern = Pattern.compile(config.getFilePatterns().getInclude(), Pattern.CASE_INSENSITIVE);
        }
        if (config.getFilePatterns().getExclude() != null) {
            this.excludePattern = Pattern.compile(config.getFilePatterns().getExclude(), Pattern.CASE_INSENSITIVE);
        }
    }
    
    /**
     * Start listening to all configured folders
     */
    public void startListening() throws Exception {
        if (config.getFolders() == null || config.getFolders().isEmpty()) {
            System.out.println("⚠️ No folders configured for listening. Please check application.yml");
            return;
        }
        
        System.out.println("🎧 Starting file listener for folders:");
        config.getFolders().forEach(folder -> System.out.println("  📁 " + folder));
        
        // First authenticate with the backend
        apiService.authenticate().block();
        
        // Create directory watcher for all configured folders
        DirectoryWatcher.Builder builder = DirectoryWatcher.builder();
        
        for (String folderPath : config.getFolders()) {
            Path path = Paths.get(folderPath);
            if (path.toFile().exists() && path.toFile().isDirectory()) {
                builder.path(path);
                System.out.println("📂 Watching: " + path.toAbsolutePath());
            } else {
                System.err.println("⚠️ Folder does not exist or is not a directory: " + folderPath);
            }
        }
        
        watcher = builder
                .listener(event -> {
                    switch (event.eventType()) {
                        case CREATE:
                            handleFileCreated(event.path());
                            break;
                        case MODIFY:
                            handleFileModified(event.path());
                            break;
                        case DELETE:
                            handleFileDeleted(event.path());
                            break;
                    }
                })
                .build();
        
        // Start watching asynchronously
        CompletableFuture<Void> future = watcher.watchAsync();
        
        System.out.println("✅ File listener started successfully. Watching for file changes...");
        System.out.println("💡 Press Ctrl+C to stop");
        
        // Keep the application running
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\n🛑 Shutting down file listener...");
            try {
                if (watcher != null) {
                    watcher.close();
                }
            } catch (Exception e) {
                System.err.println("Error closing watcher: " + e.getMessage());
            }
        }));
        
        // Wait for the future to complete (which it won't unless there's an error)
        future.join();
    }
    
    /**
     * Stop the file listener
     */
    public void stopListening() throws Exception {
        if (watcher != null) {
            watcher.close();
            System.out.println("🛑 File listener stopped");
        }
    }
    
    private void handleFileCreated(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("📝 New file detected: " + path.getFileName());
            uploadFile(path);
        }
    }
    
    private void handleFileModified(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("✏️ File modified: " + path.getFileName());
            uploadFile(path);
        }
    }
    
    private void handleFileDeleted(Path path) {
        System.out.println("🗑️ File deleted: " + path.getFileName());
        // Note: We don't delete from backend as per requirements
    }
    
    private boolean shouldProcessFile(Path path) {
        if (!path.toFile().isFile()) {
            return false;
        }
        
        String fileName = path.getFileName().toString();
        
        // Check exclude pattern first
        if (excludePattern != null && excludePattern.matcher(fileName).find()) {
            System.out.println("⏭️ Skipping excluded file: " + fileName);
            return false;
        }
        
        // Check include pattern
        if (includePattern != null && !includePattern.matcher(fileName).find()) {
            System.out.println("⏭️ Skipping file (doesn't match include pattern): " + fileName);
            return false;
        }
        
        return true;
    }
    
    private void uploadFile(Path path) {
        try {
            String mediaType = apiService.determineMediaType(path);
            
            apiService.uploadFile(path, mediaType)
                    .subscribe(
                            response -> System.out.println("✅ Successfully uploaded: " + path.getFileName() + 
                                    " -> ID: " + response.getId()),
                            error -> System.err.println("❌ Failed to upload " + path.getFileName() + 
                                    ": " + error.getMessage())
                    );
        } catch (Exception e) {
            System.err.println("❌ Error processing file " + path.getFileName() + ": " + e.getMessage());
        }
    }
}
