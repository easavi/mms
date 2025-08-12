package com.mms.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@ConditionalOnProperty(name = "storage.type", havingValue = "local")
public class LocalStorageService implements StorageService {

    @Value("${storage.local.base-path:./buckets}")
    private String basePath;

    @Override
    public String store(String bucket, MultipartFile file, String path) {
        try {
            // Get current authenticated user
            String username = getCurrentUsername();
            
            // Determine file type subfolder
            String mediaType = determineMediaType(file);
            
            // Create directory structure: buckets/{username}/{mediaType}/
            Path userDir = Paths.get(basePath, username, mediaType);
            Files.createDirectories(userDir);
            
            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueFilename = UUID.randomUUID().toString() + extension;
            
            // Full file path
            Path filePath = userDir.resolve(uniqueFilename);
            
            // Copy file to destination
            try (InputStream inputStream = file.getInputStream()) {
                Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Return relative path from buckets root
            return username + "/" + mediaType + "/" + uniqueFilename;
            
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file: " + e.getMessage(), e);
        }
    }

    @Override
    public InputStream retrieve(String bucket, String path) {
        try {
            Path filePath = Paths.get(basePath, path);
            if (!Files.exists(filePath)) {
                throw new RuntimeException("File not found: " + path);
            }
            return new FileInputStream(filePath.toFile());
        } catch (IOException e) {
            throw new RuntimeException("Failed to retrieve file: " + e.getMessage(), e);
        }
    }

    @Override
    public void delete(String bucket, String path) {
        try {
            Path filePath = Paths.get(basePath, path);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            throw new RuntimeException("Failed to delete file: " + e.getMessage(), e);
        }
    }

    @Override
    public String getUrl(String bucket, String path) {
        // For local storage, we return the path that will be handled by the content API
        return "/api/media/content?bucket=" + bucket + "&fileId=" + path;
    }

    private String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return authentication.getName();
        }
        return "anonymous"; // Fallback for unauthenticated requests
    }

    private String determineMediaType(MultipartFile file) {
        String contentType = file.getContentType();
        String filename = file.getOriginalFilename();
        
        if (contentType != null) {
            if (contentType.startsWith("image/")) {
                return "images";
            } else if (contentType.startsWith("video/")) {
                return "videos";
            } else if (contentType.startsWith("audio/")) {
                return "files"; // Audio files go to files folder
            }
        }
        
        // Fallback to extension-based detection
        if (filename != null) {
            String extension = filename.toLowerCase();
            if (extension.matches(".*\\.(jpg|jpeg|png|gif|bmp|webp|svg|ico)$")) {
                return "images";
            } else if (extension.matches(".*\\.(mp4|avi|mov|wmv|flv|webm|mkv|3gp|m4v)$")) {
                return "videos";
            }
        }
        
        return "files"; // Default to files folder
    }

    /**
     * Get the full file path for a given relative path
     */
    public Path getFilePath(String relativePath) {
        return Paths.get(basePath, relativePath);
    }

    /**
     * Check if a file exists
     */
    public boolean fileExists(String relativePath) {
        return Files.exists(Paths.get(basePath, relativePath));
    }

    /**
     * Get file size
     */
    public long getFileSize(String relativePath) throws IOException {
        Path filePath = Paths.get(basePath, relativePath);
        if (Files.exists(filePath)) {
            return Files.size(filePath);
        }
        return 0;
    }
}
