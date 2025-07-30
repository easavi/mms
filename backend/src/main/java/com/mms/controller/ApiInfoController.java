package com.mms.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiInfoController {
    
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getApiInfo() {
        Map<String, Object> apiInfo = new HashMap<>();
        
        apiInfo.put("title", "Media Management System API");
        apiInfo.put("version", "1.0.0");
        apiInfo.put("description", "REST API for managing media, storage, tags, and users");
        
        Map<String, Object> endpoints = new HashMap<>();
        
        // Storage endpoints
        Map<String, String> storageEndpoints = new HashMap<>();
        storageEndpoints.put("POST /api/storage", "Create new storage");
        storageEndpoints.put("GET /api/storage", "Get all storages");
        storageEndpoints.put("GET /api/storage/user/{username}", "Get storages by username");
        storageEndpoints.put("GET /api/storage/type/{type}", "Get storages by type (AWS/Minio)");
        storageEndpoints.put("GET /api/storage/{id}", "Get storage by ID");
        storageEndpoints.put("PUT /api/storage/{id}", "Update storage");
        storageEndpoints.put("DELETE /api/storage/{id}", "Delete storage");
        endpoints.put("storage", storageEndpoints);
        
        // Media endpoints
        Map<String, String> mediaEndpoints = new HashMap<>();
        mediaEndpoints.put("POST /api/media", "Create new media");
        mediaEndpoints.put("POST /api/media/upload", "Upload media file to MinIO bucket");
        mediaEndpoints.put("GET /api/media", "Get media with filters (startDate, endDate, tags, sort)");
        mediaEndpoints.put("GET /api/media/all", "Get all media");
        mediaEndpoints.put("GET /api/media/{id}", "Get media by ID");
        mediaEndpoints.put("PUT /api/media/{id}", "Update media");
        mediaEndpoints.put("DELETE /api/media/{id}", "Delete media");
        mediaEndpoints.put("GET /api/media/search?query=", "Search media by name or filename");
        mediaEndpoints.put("GET /api/media/grouped/month", "Get media count grouped by month");
        mediaEndpoints.put("GET /api/media/grouped/day", "Get media count grouped by day");
        mediaEndpoints.put("GET /api/media/grouped/tag", "Get media count grouped by tag");
        mediaEndpoints.put("GET /api/media/grouped/enhanced/month", "Enhanced month grouping with better structure");
        mediaEndpoints.put("GET /api/media/grouped/enhanced/day", "Enhanced day grouping with better structure");
        mediaEndpoints.put("GET /api/media/grouped/enhanced/tag", "Enhanced tag grouping with better structure");
        mediaEndpoints.put("GET /api/media/filter", "Advanced filtering with all options");
        mediaEndpoints.put("POST /api/media/filter", "Advanced filtering with request body");
        mediaEndpoints.put("GET /api/media/statistics", "Get comprehensive media statistics");
        mediaEndpoints.put("GET /api/media/validate-filter", "Validate filter parameters");
        endpoints.put("media", mediaEndpoints);
        
        // Tag endpoints
        Map<String, String> tagEndpoints = new HashMap<>();
        tagEndpoints.put("POST /api/tags", "Create new tag");
        tagEndpoints.put("GET /api/tags", "Get all tags");
        tagEndpoints.put("GET /api/tags/names", "Get all tag names only");
        tagEndpoints.put("GET /api/tags/{id}", "Get tag by ID");
        tagEndpoints.put("GET /api/tags/search?name=", "Search tags by name");
        tagEndpoints.put("PUT /api/tags/{id}", "Update tag");
        tagEndpoints.put("DELETE /api/tags/{id}", "Delete tag");
        endpoints.put("tags", tagEndpoints);
        
        // User endpoints
        Map<String, String> userEndpoints = new HashMap<>();
        userEndpoints.put("POST /api/users", "Create new user");
        userEndpoints.put("GET /api/users", "Get all users");
        userEndpoints.put("GET /api/users/{username}", "Get user by username");
        userEndpoints.put("GET /api/users/by-email?email=", "Get user by email");
        userEndpoints.put("PUT /api/users/{username}", "Update user");
        userEndpoints.put("DELETE /api/users/{username}", "Delete user");
        userEndpoints.put("GET /api/users/{username}/exists", "Check if username exists");
        userEndpoints.put("GET /api/users/email-exists?email=", "Check if email exists");
        endpoints.put("users", userEndpoints);
        
        // Demo endpoints
        Map<String, String> demoEndpoints = new HashMap<>();
        demoEndpoints.put("POST /api/demo/create", "Create demo data for testing");
        demoEndpoints.put("POST /api/demo/clear", "Get info about clearing demo data");
        demoEndpoints.put("GET /api/demo/info", "Get demo API information");
        endpoints.put("demo", demoEndpoints);
        
        apiInfo.put("endpoints", endpoints);
        
        Map<String, String> features = new HashMap<>();
        features.put("CRUD Operations", "Complete CRUD for all entities (Storage, Media, Tags, Users)");
        features.put("Media Filtering", "Filter by date range (startDate, endDate) and tags");
        features.put("Media Sorting", "Sort by createdAt date (ascending/descending)");
        features.put("Media Grouping", "Group by month, day, or tag name");
        features.put("Search", "Search media by name or filename");
        features.put("Validation", "Input validation with detailed error messages");
        features.put("Pagination", "Paginated responses for large datasets");
        apiInfo.put("features", features);
        
        return ResponseEntity.ok(apiInfo);
    }
}
