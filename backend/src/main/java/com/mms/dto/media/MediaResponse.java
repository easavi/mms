package com.mms.dto.media;

import com.mms.entity.MediaType;
import java.util.Arrays;

public class MediaResponse {
    private String id;
    private String title;
    private String description;
    private MediaType mediaType;
    private String url;
    private String[] tags;
    private String createdAt;
    private String username;

    public MediaResponse() {
    }

    public MediaResponse(String id, String title, String description, MediaType mediaType, 
                        String url, String[] tags, String createdAt, String username) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.mediaType = mediaType;
        this.url = url;
        this.tags = tags != null ? tags.clone() : null;
        this.createdAt = createdAt;
        this.username = username;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String[] getTags() {
        return tags != null ? tags.clone() : null;
    }

    public void setTags(String[] tags) {
        this.tags = tags != null ? tags.clone() : null;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        MediaResponse that = (MediaResponse) o;

        if (!id.equals(that.id)) return false;
        if (!title.equals(that.title)) return false;
        if (description != null ? !description.equals(that.description) : that.description != null) return false;
        if (mediaType != that.mediaType) return false;
        if (!url.equals(that.url)) return false;
        if (!Arrays.equals(tags, that.tags)) return false;
        if (!createdAt.equals(that.createdAt)) return false;
        return username.equals(that.username);
    }

    @Override
    public int hashCode() {
        int result = id.hashCode();
        result = 31 * result + title.hashCode();
        result = 31 * result + (description != null ? description.hashCode() : 0);
        result = 31 * result + mediaType.hashCode();
        result = 31 * result + url.hashCode();
        result = 31 * result + Arrays.hashCode(tags);
        result = 31 * result + createdAt.hashCode();
        result = 31 * result + username.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "MediaResponse{" +
                "id='" + id + '\'' +
                ", title='" + title + '\'' +
                ", description='" + description + '\'' +
                ", mediaType=" + mediaType +
                ", url='" + url + '\'' +
                ", tags=" + Arrays.toString(tags) +
                ", createdAt='" + createdAt + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
