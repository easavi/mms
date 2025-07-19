package com.mms.dto.media;

import com.mms.entity.MediaType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class MediaUploadRequest {
    @NotBlank
    private String title;
    
    private String description;
    
    @NotNull
    private MediaType mediaType;
    
    @NotNull
    private MultipartFile file;
    
    private String[] tags;
}
