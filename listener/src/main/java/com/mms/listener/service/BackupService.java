package com.mms.listener.service;

import com.mms.listener.config.MmsConfig;
import com.mms.listener.dto.MediaResponse;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.concurrent.Semaphore;

@Service
public class BackupService {
    
    private final MmsConfig config;
    private final MmsApiService apiService;
    private final Semaphore downloadSemaphore;
    
    public BackupService(MmsConfig config, MmsApiService apiService) {
        this.config = config;
        this.apiService = apiService;
        this.downloadSemaphore = new Semaphore(config.getBackup().getMaxConcurrentDownloads());
    }
    
    /**
     * Start the backup process - download all files from backend
     */
    public void startBackup() {
        System.out.println("🔄 Starting backup process...");
        
        // Create backup directory if it doesn't exist
        Path backupDir = Paths.get(config.getBackup().getDownloadFolder());
        try {
            Files.createDirectories(backupDir);
            System.out.println("📁 Backup directory: " + backupDir.toAbsolutePath());
        } catch (IOException e) {
            System.err.println("❌ Failed to create backup directory: " + e.getMessage());
            return;
        }
        
        // First authenticate with the backend
        String token = apiService.authenticate().block();
        if (token == null) {
            System.err.println("❌ Authentication failed. Cannot proceed with backup.");
            return;
        }
        
        // Get all media files from the backend
        apiService.getAllMedia()
                .doOnSuccess(mediaList -> {
                    System.out.println("📊 Found " + mediaList.size() + " files to backup");
                    startDownloads(mediaList, backupDir);
                })
                .doOnError(error -> System.err.println("❌ Failed to get media list: " + error.getMessage()))
                .subscribe();
    }
    
    private void startDownloads(List<MediaResponse> mediaList, Path backupDir) {
        Flux.fromIterable(mediaList)
                .flatMap(media -> downloadFile(media, backupDir), config.getBackup().getMaxConcurrentDownloads())
                .doOnComplete(() -> {
                    System.out.println("✅ Backup process completed!");
                    System.out.println("📁 All files saved to: " + backupDir.toAbsolutePath());
                })
                .subscribe();
    }
    
    private reactor.core.publisher.Mono<Void> downloadFile(MediaResponse media, Path backupDir) {
        return reactor.core.publisher.Mono.fromCallable(() -> {
            try {
                downloadSemaphore.acquire();
                return downloadSemaphore;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException(e);
            }
        })
        .flatMap(semaphore -> 
            apiService.downloadFileContent(media.getBucket(), media.getFileId())
                    .flatMap(fileContent -> saveFile(media, fileContent, backupDir))
                    .doFinally(signal -> semaphore.release())
        );
    }
    
    private reactor.core.publisher.Mono<Void> saveFile(MediaResponse media, byte[] fileContent, Path backupDir) {
        return reactor.core.publisher.Mono.fromRunnable(() -> {
            try {
                // Create subdirectory based on media type
                Path typeDir = backupDir.resolve(media.getMediaType());
                Files.createDirectories(typeDir);
                
                // Create filename with ID to avoid conflicts
                String filename = media.getId() + "_" + media.getFileName();
                Path filePath = typeDir.resolve(filename);
                
                // Check if file already exists
                if (Files.exists(filePath)) {
                    System.out.println("⏭️ File already exists, skipping: " + filename);
                    return;
                }
                
                // Write file content
                Files.write(filePath, fileContent, StandardOpenOption.CREATE_NEW);
                
                System.out.println("💾 Downloaded: " + filename + 
                        " (" + formatFileSize(fileContent.length) + ")");
                
            } catch (IOException e) {
                System.err.println("❌ Failed to save file " + media.getFileName() + ": " + e.getMessage());
            }
        });
    }
    
    private String formatFileSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.1f MB", bytes / (1024.0 * 1024));
        return String.format("%.1f GB", bytes / (1024.0 * 1024 * 1024));
    }
}
