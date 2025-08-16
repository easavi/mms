package com.mms.dto.media;

import java.util.Arrays;

import org.springframework.web.multipart.MultipartFile;

public class MediaUploadRequest {
    private String title;
    
    private String description;
    
    private String mediaType;
    
    private MultipartFile file;
    
    private String[] tags;
    
    private String storageId;

    public MediaUploadRequest() {
    }

    public MediaUploadRequest(String title, String description, String mediaType, MultipartFile file, String[] tags, String storageId) {
        this.title = title;
        this.description = description;
        this.mediaType = mediaType;
        this.file = file;
        this.tags = tags != null ? tags.clone() : null;
        this.storageId = storageId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public MultipartFile getFile() {
        return file;
    }

    public void setFile(MultipartFile file) {
        this.file = file;
    }

    public String[] getTags() {
        return tags != null ? tags.clone() : null;
    }

    public void setTags(String[] tags) {
        this.tags = tags != null ? tags.clone() : null;
    }

    public String getStorageId() {
        return storageId;
    }

    public void setStorageId(String storageId) {
        this.storageId = storageId;
    }
    
    // Handle tags as comma-separated string (for form submission)
    public void setTags(String tagsString) {
        if (tagsString != null && !tagsString.trim().isEmpty()) {
            this.tags = tagsString.split(",");
            // Trim whitespace from each tag
            for (int i = 0; i < this.tags.length; i++) {
                this.tags[i] = this.tags[i].trim();
            }
        } else {
            this.tags = null;
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        MediaUploadRequest that = (MediaUploadRequest) o;

        if (!title.equals(that.title)) return false;
        if (description != null ? !description.equals(that.description) : that.description != null) return false;
        if (mediaType != that.mediaType) return false;
        if (!file.equals(that.file)) return false;
        return Arrays.equals(tags, that.tags);
    }

    @Override
    public int hashCode() {
        int result = title.hashCode();
        result = 31 * result + (description != null ? description.hashCode() : 0);
        result = 31 * result + mediaType.hashCode();
        result = 31 * result + file.hashCode();
        result = 31 * result + Arrays.hashCode(tags);
        return result;
    }

    @Override
    public String toString() {
        return "MediaUploadRequest{" +
                "title='" + title + '\'' +
                ", description='" + description + '\'' +
                ", mediaType=" + mediaType +
                ", file=" + file.getOriginalFilename() +
                ", tags=" + Arrays.toString(tags) +
                '}';
    }
}
