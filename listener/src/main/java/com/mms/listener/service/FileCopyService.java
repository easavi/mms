package com.mms.listener.service;

import com.mms.listener.config.MmsConfig;
import io.methvin.watcher.DirectoryWatcher;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.*;
import java.util.concurrent.CompletableFuture;
import java.util.regex.Pattern;
import java.util.stream.Stream;

@Service
public class FileCopyService {
    
    private final MmsConfig config;
    private DirectoryWatcher watcher;
    private Pattern includePattern;
    private Pattern excludePattern;
    
    public FileCopyService(MmsConfig config) {
        this.config = config;
        
        // Compile regex patterns for file filtering
        if (config.getFilePatterns().getInclude() != null) {
            this.includePattern = Pattern.compile(config.getFilePatterns().getInclude(), Pattern.CASE_INSENSITIVE);
        }
        if (config.getFilePatterns().getExclude() != null) {
            this.excludePattern = Pattern.compile(config.getFilePatterns().getExclude(), Pattern.CASE_INSENSITIVE);
        }
    }
    
    /**
     * Start listening to all configured source folders and copy files to destination folders
     */
    public void startFileCopyService() throws Exception {
        if (config.getFolderCopyMappings() == null || config.getFolderCopyMappings().isEmpty()) {
            System.out.println("⚠️ No folder copy mappings configured. Please check application.yml");
            return;
        }
        
        System.out.println("🗂️ Starting file copy service for folder mappings:");
        config.getFolderCopyMappings().forEach(mapping -> 
            System.out.println("  📁 " + mapping.getSource() + " -> " + mapping.getDestination()));
        
        // Create destination directories if they don't exist
        createDestinationDirectories();
        
        // Copy existing files before starting watcher
        copyExistingFiles();
        
        // Create directory watcher for all configured source folders
        DirectoryWatcher.Builder builder = DirectoryWatcher.builder();
        
        for (MmsConfig.FolderCopyMapping mapping : config.getFolderCopyMappings()) {
            Path sourcePath = Paths.get(mapping.getSource());
            if (sourcePath.toFile().exists() && sourcePath.toFile().isDirectory()) {
                builder.path(sourcePath);
                System.out.println("👀 Watching source: " + sourcePath.toAbsolutePath());
            } else {
                System.err.println("⚠️ Source folder does not exist or is not a directory: " + mapping.getSource());
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
        
        System.out.println("✅ File copy service started successfully. Watching for file changes...");
        System.out.println("💡 Press Ctrl+C to stop");
        
        // Keep the application running
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\n🛑 Shutting down file copy service...");
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
     * Stop the file copy service
     */
    public void stopFileCopyService() throws Exception {
        if (watcher != null) {
            watcher.close();
            System.out.println("🛑 File copy service stopped");
        }
    }
    
    /**
     * Create destination directories if they don't exist
     */
    private void createDestinationDirectories() {
        System.out.println("📁 Creating destination directories...");
        
        for (MmsConfig.FolderCopyMapping mapping : config.getFolderCopyMappings()) {
            Path destinationPath = Paths.get(mapping.getDestination());
            if (!Files.exists(destinationPath)) {
                try {
                    Files.createDirectories(destinationPath);
                    System.out.println("✅ Created destination directory: " + destinationPath.toAbsolutePath());
                } catch (IOException e) {
                    System.err.println("❌ Failed to create destination directory " + destinationPath + ": " + e.getMessage());
                }
            } else {
                System.out.println("📂 Destination directory already exists: " + destinationPath.toAbsolutePath());
            }
        }
    }
    
    /**
     * Copy all existing files from source to destination folders
     */
    private void copyExistingFiles() {
        System.out.println("🔍 Copying existing files...");
        
        for (MmsConfig.FolderCopyMapping mapping : config.getFolderCopyMappings()) {
            Path sourcePath = Paths.get(mapping.getSource());
            Path destinationPath = Paths.get(mapping.getDestination());
            
            if (sourcePath.toFile().exists() && sourcePath.toFile().isDirectory()) {
                copyDirectoryFiles(sourcePath, destinationPath);
            }
        }
        
        System.out.println("✅ Finished copying existing files");
    }
    
    /**
     * Recursively copy all files from source directory to destination directory
     */
    private void copyDirectoryFiles(Path sourceDir, Path destinationDir) {
        try (Stream<Path> paths = Files.walk(sourceDir)) {
            paths.filter(Files::isRegularFile)
                 .filter(this::shouldProcessFile)
                 .forEach(sourcePath -> {
                     try {
                         // Calculate relative path from source root
                         Path relativePath = sourceDir.relativize(sourcePath);
                         Path destPath = destinationDir.resolve(relativePath);
                         
                         // Create parent directories if they don't exist
                         Files.createDirectories(destPath.getParent());
                         
                         // Copy file if it doesn't exist or if source is newer
                         if (!Files.exists(destPath) || Files.getLastModifiedTime(sourcePath).compareTo(Files.getLastModifiedTime(destPath)) > 0) {
                             Files.copy(sourcePath, destPath, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES);
                             System.out.println("📄 Copied existing file: " + sourcePath.getFileName() + " -> " + destPath);
                         }
                     } catch (IOException e) {
                         System.err.println("❌ Error copying file " + sourcePath + ": " + e.getMessage());
                     }
                 });
        } catch (IOException e) {
            System.err.println("❌ Error scanning source directory " + sourceDir + ": " + e.getMessage());
        }
    }

    private void handleFileCreated(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("📝 New file detected: " + path.getFileName());
            copyFileToDestination(path);
        }
    }
    
    private void handleFileModified(Path path) {
        if (shouldProcessFile(path)) {
            System.out.println("✏️ File modified: " + path.getFileName());
            copyFileToDestination(path);
        }
    }
    
    private void handleFileDeleted(Path path) {
        System.out.println("🗑️ File deleted: " + path.getFileName());
        // Note: We don't delete from destination as this is a backup/copy service
        System.out.println("💡 File remains in destination folder (backup preserved)");
    }
    
    /**
     * Check if a file should be processed based on include/exclude patterns
     */
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
     * Copy a file from source to the appropriate destination folder
     */
    private void copyFileToDestination(Path sourcePath) {
        try {
            // Find the appropriate mapping for this source path
            MmsConfig.FolderCopyMapping mapping = findMappingForPath(sourcePath);
            if (mapping == null) {
                System.err.println("⚠️ No mapping found for file: " + sourcePath);
                return;
            }
            
            Path sourceDir = Paths.get(mapping.getSource());
            Path destinationDir = Paths.get(mapping.getDestination());
            
            // Calculate relative path from source root
            Path relativePath = sourceDir.relativize(sourcePath);
            Path destPath = destinationDir.resolve(relativePath);
            
            // Create parent directories if they don't exist
            Files.createDirectories(destPath.getParent());
            
            // Copy file with attributes
            Files.copy(sourcePath, destPath, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES);
            
            System.out.println("✅ Successfully copied: " + sourcePath.getFileName() + " -> " + destPath);
            
        } catch (IOException e) {
            System.err.println("❌ Failed to copy file " + sourcePath.getFileName() + ": " + e.getMessage());
        }
    }
    
    /**
     * Find the mapping configuration for a given source path
     */
    private MmsConfig.FolderCopyMapping findMappingForPath(Path sourcePath) {
        for (MmsConfig.FolderCopyMapping mapping : config.getFolderCopyMappings()) {
            Path sourceDir = Paths.get(mapping.getSource());
            if (sourcePath.startsWith(sourceDir)) {
                return mapping;
            }
        }
        return null;
    }
}
