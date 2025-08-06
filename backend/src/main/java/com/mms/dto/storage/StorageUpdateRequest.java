package com.mms.dto.storage;

public class StorageUpdateRequest {
    
    private String path; // Only path can be updated
    
    public StorageUpdateRequest() {
    }
    
    public StorageUpdateRequest(String path) {
        this.path = path;
    }
    
    public String getPath() {
        return path;
    }
    
    public void setPath(String path) {
        this.path = path;
    }
}
