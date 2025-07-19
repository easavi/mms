package com.mms.dto;

import com.mms.entity.MediaType;
import lombok.Data;

@Data
public class MediaResponse {
    private String id;
    private String title;
    private String description;
    private MediaType mediaType;
    private String url;
    private String[] tags;
    private String createdAt;
    private String username;
}
