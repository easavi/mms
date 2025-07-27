package com.mms.dto.media;

import org.springframework.format.annotation.DateTimeFormat;

import java.time.OffsetDateTime;
import java.util.List;

public class MediaFilterRequest {
    
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private OffsetDateTime startDate;
    
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private OffsetDateTime endDate;
    
    private List<String> tagNames;
    
    private String sortDirection = "desc"; // Default to descending
    
    private String groupBy; // "month", "day", "tag"
    
    private String searchQuery;
    
    public MediaFilterRequest() {
    }
    
    public MediaFilterRequest(OffsetDateTime startDate, OffsetDateTime endDate, 
                             List<String> tagNames, String sortDirection, String groupBy) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.tagNames = tagNames;
        this.sortDirection = sortDirection;
        this.groupBy = groupBy;
    }
    
    public OffsetDateTime getStartDate() {
        return startDate;
    }
    
    public void setStartDate(OffsetDateTime startDate) {
        this.startDate = startDate;
    }
    
    public OffsetDateTime getEndDate() {
        return endDate;
    }
    
    public void setEndDate(OffsetDateTime endDate) {
        this.endDate = endDate;
    }
    
    public List<String> getTagNames() {
        return tagNames;
    }
    
    public void setTagNames(List<String> tagNames) {
        this.tagNames = tagNames;
    }
    
    public String getSortDirection() {
        return sortDirection;
    }
    
    public void setSortDirection(String sortDirection) {
        this.sortDirection = sortDirection;
    }
    
    public String getGroupBy() {
        return groupBy;
    }
    
    public void setGroupBy(String groupBy) {
        this.groupBy = groupBy;
    }
    
    public String getSearchQuery() {
        return searchQuery;
    }
    
    public void setSearchQuery(String searchQuery) {
        this.searchQuery = searchQuery;
    }
    
    public boolean hasDateFilter() {
        return startDate != null && endDate != null;
    }
    
    public boolean hasTagFilter() {
        return tagNames != null && !tagNames.isEmpty();
    }
    
    public boolean hasSearchQuery() {
        return searchQuery != null && !searchQuery.trim().isEmpty();
    }
    
    public boolean isAscending() {
        return "asc".equalsIgnoreCase(sortDirection);
    }
}
