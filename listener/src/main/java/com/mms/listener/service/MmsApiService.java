package com.mms.listener.service;

import com.mms.listener.config.MmsConfig;
import com.mms.listener.dto.AuthResponse;
import com.mms.listener.dto.LoginRequest;
import com.mms.listener.dto.MediaResponse;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.io.File;
import java.nio.file.Path;
import java.time.Duration;
import java.util.List;

@Service
public class MmsApiService {
    
    private final WebClient webClient;
    private final MmsConfig config;
    private String authToken;
    
    public MmsApiService(MmsConfig config) {
        this.config = config;
        this.webClient = WebClient.builder()
                .baseUrl(config.getBackend().getUrl())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(50 * 1024 * 1024)) // 50MB buffer
                .build();
    }
    
    /**
     * Authenticate with the backend and get JWT token
     */
    public Mono<String> authenticate() {
        LoginRequest loginRequest = new LoginRequest(
                config.getBackend().getUsername(),
                config.getBackend().getPassword()
        );
        
        return webClient.post()
                .uri("/auth/login")
                .body(BodyInserters.fromValue(loginRequest))
                .retrieve()
                .bodyToMono(AuthResponse.class)
                .map(response -> {
                    this.authToken = response.getToken();
                    System.out.println("✅ Authentication successful for user: " + response.getUsername());
                    return response.getToken();
                })
                .doOnError(error -> System.err.println("❌ Authentication failed: " + error.getMessage()));
    }
    
    /**
     * Upload a file to the backend
     */
    public Mono<MediaResponse> uploadFile(Path filePath, String mediaType) {
        if (authToken == null) {
            return authenticate().flatMap(token -> doUploadFile(filePath, mediaType));
        }
        return doUploadFile(filePath, mediaType);
    }
    
    private Mono<MediaResponse> doUploadFile(Path filePath, String mediaType) {
        File file = filePath.toFile();
        String fileName = file.getName();
        
        MultiValueMap<String, Object> parts = new LinkedMultiValueMap<>();
        parts.add("file", new FileSystemResource(file));
        parts.add("title", fileName);
        parts.add("description", "Uploaded by MMS Listener");
        parts.add("mediaType", mediaType);
        parts.add("tags", "listener,auto-upload");
        
        return webClient.post()
                .uri("/api/media/upload")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + authToken)
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .body(BodyInserters.fromMultipartData(parts))
                .retrieve()
                .bodyToMono(MediaResponse.class)
                .doOnSuccess(response -> 
                    System.out.println("📤 File uploaded successfully: " + fileName + " (ID: " + response.getId() + ")")
                )
                .doOnError(error -> {
                    System.err.println("❌ Failed to upload file " + fileName + ": " + error.getMessage());
                    // If authentication error, clear token to force re-authentication
                    if (error.getMessage().contains("401") || error.getMessage().contains("Unauthorized")) {
                        this.authToken = null;
                    }
                })
                .onErrorResume(throwable -> {
                    // Retry with fresh authentication if upload failed
                    if (throwable.getMessage().contains("401") || throwable.getMessage().contains("Unauthorized")) {
                        return authenticate().flatMap(token -> doUploadFile(filePath, mediaType));
                    }
                    return Mono.error(throwable);
                });
    }
    
    /**
     * Get all media files from the backend
     */
    public Mono<List<MediaResponse>> getAllMedia() {
        if (authToken == null) {
            return authenticate().flatMap(token -> doGetAllMedia());
        }
        return doGetAllMedia();
    }
    
    private Mono<List<MediaResponse>> doGetAllMedia() {
        return webClient.get()
                .uri("/api/media/all")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + authToken)
                .retrieve()
                .bodyToFlux(MediaResponse.class)
                .collectList()
                .doOnError(error -> {
                    System.err.println("❌ Failed to get media list: " + error.getMessage());
                    if (error.getMessage().contains("401") || error.getMessage().contains("Unauthorized")) {
                        this.authToken = null;
                    }
                })
                .onErrorResume(throwable -> {
                    if (throwable.getMessage().contains("401") || throwable.getMessage().contains("Unauthorized")) {
                        return authenticate().flatMap(token -> doGetAllMedia());
                    }
                    return Mono.error(throwable);
                });
    }
    
    /**
     * Download file content from the backend
     */
    public Mono<byte[]> downloadFileContent(String bucket, String fileId) {
        if (authToken == null) {
            return authenticate().flatMap(token -> doDownloadFileContent(bucket, fileId));
        }
        return doDownloadFileContent(bucket, fileId);
    }
    
    private Mono<byte[]> doDownloadFileContent(String bucket, String fileId) {
        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/media/content")
                        .queryParam("bucket", bucket)
                        .queryParam("fileId", fileId)
                        .build())
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + authToken)
                .retrieve()
                .bodyToMono(byte[].class)
                .timeout(Duration.ofMinutes(5))
                .doOnError(error -> {
                    System.err.println("❌ Failed to download file " + fileId + ": " + error.getMessage());
                    if (error.getMessage().contains("401") || error.getMessage().contains("Unauthorized")) {
                        this.authToken = null;
                    }
                })
                .onErrorResume(throwable -> {
                    if (throwable.getMessage().contains("401") || throwable.getMessage().contains("Unauthorized")) {
                        return authenticate().flatMap(token -> doDownloadFileContent(bucket, fileId));
                    }
                    return Mono.error(throwable);
                });
    }
    
    /**
     * Determine media type based on file extension
     */
    public String determineMediaType(Path filePath) {
        String fileName = filePath.getFileName().toString().toLowerCase();
        
        if (fileName.matches(".*\\.(jpg|jpeg|png|gif|bmp|webp|svg)$")) {
            return "image";
        } else if (fileName.matches(".*\\.(mp4|avi|mov|wmv|flv|mkv|webm)$")) {
            return "video";
        } else if (fileName.matches(".*\\.(mp3|wav|flac|aac|ogg|wma)$")) {
            return "audio";
        } else {
            return "file";
        }
    }
}
