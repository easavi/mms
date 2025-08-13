package com.mms.service;

import net.coobird.thumbnailator.Thumbnails;
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
            
            // Generate thumbnail if it's an image
            if ("images".equals(mediaType)) {
                generateThumbnail(filePath, uniqueFilename);
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

    /**
     * Generate a thumbnail for an image file
     * Thumbnail will be saved in the same directory with "_thumb_" prefix
     */
    private void generateThumbnail(Path originalImagePath, String originalFilename) {
        try {
            // Create thumbnail filename with _thumb_ prefix
            String thumbnailFilename = "_thumb_" + originalFilename;
            Path thumbnailPath = originalImagePath.getParent().resolve(thumbnailFilename);
            
            // Generate 256x256 thumbnail
            Thumbnails.of(originalImagePath.toFile())
                    .size(256, 256)
                    .keepAspectRatio(true)
                    .toFile(thumbnailPath.toFile());
            
            System.out.println("✅ Thumbnail generated: " + thumbnailPath);
            
        } catch (IOException e) {
            // Log error but don't fail the main upload process
            System.err.println("❌ Failed to generate thumbnail for " + originalFilename + ": " + e.getMessage());
        } catch (Exception e) {
            // Catch any other exceptions (e.g., unsupported image format)
            System.err.println("❌ Thumbnail generation failed for " + originalFilename + ": " + e.getMessage());
        }
    }

    /**
     * Get the thumbnail path for a given image file
     * @param originalRelativePath The relative path of the original image (e.g., "username/images/uuid.jpg")
     * @return The relative path of the thumbnail or null if thumbnail doesn't exist
     */
    public String getThumbnailPath(String originalRelativePath) {
        try {
            // Extract the directory and filename
            Path originalPath = Paths.get(originalRelativePath);
            Path directory = originalPath.getParent();
            String originalFilename = originalPath.getFileName().toString();
            
            // Create thumbnail filename
            String thumbnailFilename = "_thumb_" + originalFilename;
            
            // Build full thumbnail path
            String thumbnailRelativePath = directory.resolve(thumbnailFilename).toString().replace("\\", "/");
            
            // Check if thumbnail exists
            if (fileExists(thumbnailRelativePath)) {
                return thumbnailRelativePath;
            }
            
            return null;
        } catch (Exception e) {
            System.err.println("❌ Error getting thumbnail path for " + originalRelativePath + ": " + e.getMessage());
            return null;
        }
    }

    /**
     * Check if a file is an image based on its path
     */
    public boolean isImageFile(String relativePath) {
        if (relativePath == null) return false;
        
        String filename = Paths.get(relativePath).getFileName().toString().toLowerCase();
        return filename.matches(".*\\.(jpg|jpeg|png|gif|bmp|webp|svg|ico)$");
    }
}
