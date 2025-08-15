package com.mms.listener.service;

import com.mms.listener.config.MmsConfig;
import io.methvin.watcher.DirectoryWatcher;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.*;
import java.util.regex.Pattern;
import java.util.stream.Stream;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class FileListenerService {
    
    private final MmsConfig config;
    private final MmsApiService apiService;
    private DirectoryWatcher watcher;
    private Pattern includePattern;
    private Pattern excludePattern;
    
    // File monitoring for stability check
    private final Map<Path, FileMonitorInfo> fileMonitorMap = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(10);
    
    // Inner class to track file monitoring information
    private static class FileMonitorInfo {
        final AtomicLong lastSize = new AtomicLong(0);
        volatile boolean isStabilityChecking = false;
        
        FileMonitorInfo(long initialSize) {
            lastSize.set(initialSize);
        }
    }
    
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
        
        // Scan and upload existing files before starting watcher
        scanAndUploadExistingFiles();
        
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
                        case OVERFLOW:
                            System.out.println("⚠️ Directory watcher overflow event");
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
                scheduler.shutdown();
                try {
                    if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                        scheduler.shutdownNow();
                    }
                } catch (InterruptedException e) {
                    scheduler.shutdownNow();
                    Thread.currentThread().interrupt();
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
        }
        
        // Shutdown the scheduler
        scheduler.shutdown();
        try {
            if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                scheduler.shutdownNow();
            }
        } catch (InterruptedException e) {
            scheduler.shutdownNow();
            Thread.currentThread().interrupt();
        }
        
        // Clear the monitoring map
        fileMonitorMap.clear();
        
        System.out.println("🛑 File listener stopped");
    }
    
    /**
     * Scan all configured folders for existing files and upload them
     */
    private void scanAndUploadExistingFiles() {
        System.out.println("🔍 Scanning for existing files...");
        
        for (String folderPath : config.getFolders()) {
            Path path = Paths.get(folderPath);
            if (path.toFile().exists() && path.toFile().isDirectory()) {
                scanDirectoryForFiles(path);
            }
        }
        
        System.out.println("✅ Finished scanning existing files");
    }
    
    /**
     * Recursively scan a directory for files and upload them
     */
    private void scanDirectoryForFiles(Path directory) {
        try (Stream<Path> paths = Files.walk(directory)) {
            paths.filter(Files::isRegularFile)
                 .filter(this::shouldProcessFile)
                 .forEach(path -> {
                     System.out.println("📁 Found existing file: " + path.getFileName());
                     scheduleFileSizeCheck(path);
                 });
        } catch (IOException e) {
            System.err.println("❌ Error scanning directory " + directory + ": " + e.getMessage());
        }
    }

    private void handleFileCreated(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("📝 New file detected: " + path.getFileName());
            scheduleFileSizeCheck(path);
        }
    }
    
    private void handleFileModified(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("✏️ File modified: " + path.getFileName());
            scheduleFileSizeCheck(path);
        }
    }
    
    private void handleFileDeleted(Path path) {
        System.out.println("🗑️ File deleted: " + path.getFileName());
        // Remove from monitoring map
        fileMonitorMap.remove(path);
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
    
    /**
     * Schedule a file size check to ensure the file is stable before uploading
     */
    private void scheduleFileSizeCheck(Path path) {
        try {
            if (!Files.exists(path) || !Files.isRegularFile(path)) {
                return;
            }
            
            long currentSize = Files.size(path);
            FileMonitorInfo monitorInfo = fileMonitorMap.computeIfAbsent(path, _ -> new FileMonitorInfo(currentSize));
            
            // Update the current size
            monitorInfo.lastSize.set(currentSize);
            
            if (monitorInfo.isStabilityChecking) {
                // Already checking this file, just update the size
                System.out.println("🔄 File size updated during check: " + path.getFileName() + " (size: " + currentSize + " bytes)");
                return;
            }
            
            // Start the stability check process
            monitorInfo.isStabilityChecking = true;
            System.out.println("⏱️ Starting stability check for: " + path.getFileName() + " (size: " + currentSize + " bytes)");
            
            // Schedule first check after 5 seconds
            scheduler.schedule(() -> performSizeCheck(path, false), 5, TimeUnit.SECONDS);
            
        } catch (IOException e) {
            System.err.println("❌ Error getting file size for " + path.getFileName() + ": " + e.getMessage());
            fileMonitorMap.remove(path);
        }
    }
    
    /**
     * Perform the actual size check and decide whether to upload or wait more
     */
    private void performSizeCheck(Path path, boolean isSecondCheck) {
        try {
            if (!Files.exists(path) || !Files.isRegularFile(path)) {
                System.out.println("⚠️ File no longer exists during stability check: " + path.getFileName());
                fileMonitorMap.remove(path);
                return;
            }
            
            FileMonitorInfo monitorInfo = fileMonitorMap.get(path);
            if (monitorInfo == null) {
                return; // File was removed from monitoring
            }
            
            long currentSize = Files.size(path);
            long previousSize = monitorInfo.lastSize.get();
            
            if (currentSize != previousSize) {
                // Size changed, update and restart the check
                monitorInfo.lastSize.set(currentSize);
                System.out.println("📏 File size changed during check: " + path.getFileName() + 
                                 " (" + previousSize + " -> " + currentSize + " bytes). Restarting stability check...");
                
                // Reschedule for another 5 seconds
                scheduler.schedule(() -> performSizeCheck(path, false), 5, TimeUnit.SECONDS);
            } else {
                // Size is the same
                if (!isSecondCheck) {
                    // First check passed, wait additional 10 seconds for final verification
                    System.out.println("✅ First stability check passed for: " + path.getFileName() + 
                                     " (size stable: " + currentSize + " bytes). Waiting 10 more seconds...");
                    scheduler.schedule(() -> performSizeCheck(path, true), 10, TimeUnit.SECONDS);
                } else {
                    // Second check passed, file is stable - proceed with upload
                    System.out.println("🎯 File is stable after verification: " + path.getFileName() + 
                                     " (size: " + currentSize + " bytes). Proceeding with upload...");
                    monitorInfo.isStabilityChecking = false;
                    fileMonitorMap.remove(path);
                    uploadFile(path);
                }
            }
            
        } catch (IOException e) {
            System.err.println("❌ Error during size check for " + path.getFileName() + ": " + e.getMessage());
            fileMonitorMap.remove(path);
        }
    }
    
    private void uploadFile(Path path) {
        try {
            String mediaType = apiService.determineMediaType(path);
            
            apiService.uploadFile(path, mediaType)
                    .subscribe(
                            response -> {
                                System.out.println("✅ Successfully uploaded: " + path.getFileName() + 
                                        " -> ID: " + response.getId());
                                // Delete file after successful upload
                                deleteFileAfterUpload(path);
                            },
                            error -> System.err.println("❌ Failed to upload " + path.getFileName() + 
                                    ": " + error.getMessage())
                    );
        } catch (Exception e) {
            System.err.println("❌ Error processing file " + path.getFileName() + ": " + e.getMessage());
        }
    }
    
    /**
     * Delete file after successful upload
     */
    private void deleteFileAfterUpload(Path path) {
        try {
            Files.delete(path);
            System.out.println("🗑️ Deleted uploaded file: " + path.getFileName());
        } catch (IOException e) {
            System.err.println("⚠️ Failed to delete file after upload " + path.getFileName() + ": " + e.getMessage());
        }
    }
}
