package com.mms.dto.media;

import java.util.List;

public class GroupedMediaResponse {
    
    private String groupKey;
    private String groupType; // "month", "day", "tag"
    private Long count;
    private List<MediaResponseNew> items;
    
    public GroupedMediaResponse() {
    }
    
    public GroupedMediaResponse(String groupKey, String groupType, Long count) {
        this.groupKey = groupKey;
        this.groupType = groupType;
        this.count = count;
    }
    
    public GroupedMediaResponse(String groupKey, String groupType, Long count, List<MediaResponseNew> items) {
        this.groupKey = groupKey;
        this.groupType = groupType;
        this.count = count;
        this.items = items;
    }
    
    public String getGroupKey() {
        return groupKey;
    }
    
    public void setGroupKey(String groupKey) {
        this.groupKey = groupKey;
    }
    
    public String getGroupType() {
        return groupType;
    }
    
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }
    
    public Long getCount() {
        return count;
    }
    
    public void setCount(Long count) {
        this.count = count;
    }
    
    public List<MediaResponseNew> getItems() {
        return items;
    }
    
    public void setItems(List<MediaResponseNew> items) {
        this.items = items;
    }
}
