package com.mms.listener.util;

import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

/**
 * Utility class for file operations and validation
 */
public class FileUtils {
    
    private static final int MAX_WAIT_ATTEMPTS = 10;
    private static final long WAIT_INTERVAL_MS = 500;
    
    /**
     * Wait for a file to be completely written by checking if its size stabilizes
     * and if it can be opened for reading exclusively.
     * 
     * @param path The path to the file to check
     * @return true if the file is complete and ready for processing, false otherwise
     */
    public static boolean waitForFileCompletion(Path path) {
        if (!Files.exists(path)) {
            return false;
        }
        
        try {
            long previousSize = -1;
            int stableSizeCount = 0;
            
            for (int attempt = 0; attempt < MAX_WAIT_ATTEMPTS; attempt++) {
                // Check if file still exists
                if (!Files.exists(path)) {
                    return false;
                }
                
                // Get current file size
                long currentSize;
                try {
                    currentSize = Files.size(path);
                } catch (IOException e) {
                    // File might be locked or being written, wait and retry
                    System.out.println("⏳ File size check failed, waiting... (" + path.getFileName() + ")");
                    sleepQuietly(WAIT_INTERVAL_MS);
                    continue;
                }
                
                // Check if size has stabilized
                if (currentSize == previousSize && currentSize > 0) {
                    stableSizeCount++;
                    if (stableSizeCount >= 2) {
                        // Size has been stable for at least 2 checks, now test file access
                        if (isFileAccessible(path)) {
                            System.out.println("✅ File is complete and ready: " + path.getFileName() + " (" + currentSize + " bytes)");
                            return true;
                        }
                    }
                } else {
                    stableSizeCount = 0;
                    previousSize = currentSize;
                }
                
                if (attempt < MAX_WAIT_ATTEMPTS - 1) {
                    System.out.println("⏳ Waiting for file to complete... (" + path.getFileName() + 
                            " - Size: " + currentSize + ", Attempt: " + (attempt + 1) + ")");
                    sleepQuietly(WAIT_INTERVAL_MS);
                }
            }
            
            System.out.println("⚠️ File completion timeout reached: " + path.getFileName());
            return false;
            
        } catch (Exception e) {
            System.err.println("❌ Error waiting for file completion " + path + ": " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Check if a file is accessible for reading by trying to open it exclusively
     */
    private static boolean isFileAccessible(Path path) {
        try {
            // Try to open the file for reading
            try (FileChannel channel = FileChannel.open(path, StandardOpenOption.READ)) {
                // If we can open it successfully, the file should be complete
                return channel != null;
            }
        } catch (IOException e) {
            // File is likely still being written or locked
            System.out.println("⏳ File still locked or being written: " + path.getFileName());
            return false;
        }
    }
    
    /**
     * Check if a file has a temporary or incomplete file extension
     */
    public static boolean hasTemporaryExtension(String fileName) {
        String lowerName = fileName.toLowerCase();
        return lowerName.endsWith(".tmp") || 
               lowerName.endsWith(".temp") || 
               lowerName.endsWith(".partial") ||
               lowerName.endsWith(".download") ||
               lowerName.endsWith(".crdownload") || // Chrome downloads
               lowerName.endsWith(".part") ||       // Firefox downloads
               lowerName.startsWith("~") ||         // Office temp files
               lowerName.startsWith(".~");          // Hidden temp files
    }
    
    /**
     * Sleep quietly without throwing InterruptedException
     */
    private static void sleepQuietly(long milliseconds) {
        try {
            Thread.sleep(milliseconds);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    /**
     * Get a human-readable file size string
     */
    public static String getFileSizeString(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.1f MB", bytes / (1024.0 * 1024.0));
        return String.format("%.1f GB", bytes / (1024.0 * 1024.0 * 1024.0));
    }
}
