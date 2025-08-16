package com.mms.dto.storage;

import jakarta.validation.constraints.NotBlank;

public class StorageCreateRequest {
    
    @NotBlank(message = "Path is required")
    private String path; // Path to local folder on device
    
    @NotBlank(message = "Device ID is required")
    private String deviceId; // Device identifier
    
    // Type is always "server" - set automatically in backend
    // Bucket is auto-generated - not needed in request
    // Username is set from JWT token - not needed in request
    
    public StorageCreateRequest() {
    }
    
    public StorageCreateRequest(String path, String deviceId) {
        this.path = path;
        this.deviceId = deviceId;
    }
    
    public String getPath() {
        return path;
    }
    
    public void setPath(String path) {
        this.path = path;
    }

    public String getDeviceId() {
        return deviceId;
    }
    
    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }
}
