package com.mms.dto.storage;

import jakarta.validation.constraints.NotBlank;

public class StorageCreateRequest {
    
    @NotBlank(message = "Path is required")
    private String path; // Path to local folder on device
    
    // Type is always "server" - set automatically in backend
    // Bucket is auto-generated - not needed in request
    // Username is set from JWT token - not needed in request
    
    public StorageCreateRequest() {
    }
    
    public StorageCreateRequest(String path) {
        this.path = path;
    }
    
    public String getPath() {
        return path;
    }
    
    public void setPath(String path) {
        this.path = path;
    }
}
