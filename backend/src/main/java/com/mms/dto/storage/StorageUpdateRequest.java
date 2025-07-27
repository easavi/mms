package com.mms.dto.storage;

public class StorageUpdateRequest {
    
    private String name;
    private String bucket;
    private Long size;
    private Integer itemsQuantity;
    
    public StorageUpdateRequest() {
    }
    
    public StorageUpdateRequest(String name, String bucket, Long size, Integer itemsQuantity) {
        this.name = name;
        this.bucket = bucket;
        this.size = size;
        this.itemsQuantity = itemsQuantity;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getBucket() {
        return bucket;
    }
    
    public void setBucket(String bucket) {
        this.bucket = bucket;
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
