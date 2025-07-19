package com.mms.dto.media;

import com.mms.entity.MediaType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.web.multipart.MultipartFile;
import java.util.Arrays;

public class MediaUploadRequest {
    @NotBlank
    private String title;
    
    private String description;
    
    @NotNull
    private MediaType mediaType;
    
    @NotNull
    private MultipartFile file;
    
    private String[] tags;

    public MediaUploadRequest() {
    }

    public MediaUploadRequest(String title, String description, MediaType mediaType, MultipartFile file, String[] tags) {
        this.title = title;
        this.description = description;
        this.mediaType = mediaType;
        this.file = file;
        this.tags = tags != null ? tags.clone() : null;
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

    public MediaType getMediaType() {
        return mediaType;
    }

    public void setMediaType(MediaType mediaType) {
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
