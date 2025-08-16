package com.mms.dto.storage;

public class StorageResponse {
    
    private String id;
    private String bucket;    // Auto-generated, first 8 digits of UUID
    private String path;      // Path to local folder on device
    private String type;      // Always "server", but included for completeness
    private String updated;   // Timestamp
    private String username;  // User owning this storage
    private String deviceId;  // Device identifier
    private Long size;        // Total size in bytes (calculated dynamically)
    private Integer itemsQuantity; // Number of items (calculated dynamically)
    
    public StorageResponse() {
    }
    
    public StorageResponse(String id, String bucket, String path, String type, 
                          String updated, String username, String deviceId, Long size, Integer itemsQuantity) {
        this.id = id;
        this.bucket = bucket;
        this.path = path;
        this.type = type;
        this.updated = updated;
        this.username = username;
        this.deviceId = deviceId;
        this.size = size;
        this.itemsQuantity = itemsQuantity;
    }
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getBucket() {
        return bucket;
    }
    
    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String getPath() {
        return path;
    }
    
    public void setPath(String path) {
        this.path = path;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getUpdated() {
        return updated;
    }
    
    public void setUpdated(String updated) {
        this.updated = updated;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public Integer getItemsQuantity() {
        return itemsQuantity;
    }

    public void setItemsQuantity(Integer itemsQuantity) {
        this.itemsQuantity = itemsQuantity;
    }
}
