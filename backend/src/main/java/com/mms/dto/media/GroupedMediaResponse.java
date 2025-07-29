package com.mms.dto.media;

import java.util.List;

public class GroupedMediaResponse {
    
    private String groupKey;
    private String groupType; // "month", "day", "tag"
    private Long count;
    private List<MediaResponse> items;
    
    public GroupedMediaResponse() {
    }
    
    public GroupedMediaResponse(String groupKey, String groupType, Long count) {
        this.groupKey = groupKey;
        this.groupType = groupType;
        this.count = count;
    }
    
    public GroupedMediaResponse(String groupKey, String groupType, Long count, List<MediaResponse> items) {
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
    
    public List<MediaResponse> getItems() {
        return items;
    }
    
    public void setItems(List<MediaResponse> items) {
        this.items = items;
    }
}
