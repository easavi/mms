package com.mms.controller;

import com.mms.service.ValidationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/validation")
public class ValidationController {
    
    private final ValidationService validationService;
    
    public ValidationController(ValidationService validationService) {
        this.validationService = validationService;
    }
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> validateSystemHealth() {
        Map<String, Object> health = validationService.validateSystemHealth();
        return ResponseEntity.ok(health);
    }
    
    @GetMapping("/features")
    public ResponseEntity<Map<String, Object>> validateAdvancedFeatures() {
        Map<String, Object> validation = validationService.validateAdvancedFeatures();
        return ResponseEntity.ok(validation);
    }
    
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getValidationInfo() {
        Map<String, Object> info = Map.of(
            "title", "System Validation",
            "description", "Validate that all system components and advanced features are working correctly",
            "endpoints", Map.of(
                "GET /api/validation/health", "Check system health and database connectivity",
                "GET /api/validation/features", "Test advanced filtering and querying features",
                "GET /api/validation/info", "Get validation API information"
            ),
            "healthChecks", Map.of(
                "database", "Connection and basic operations",
                "repositories", "All repository methods",
                "grouping", "Month/day/tag grouping queries",
                "counts", "Entity counts"
            ),
            "featureTests", Map.of(
                "dateFiltering", "Date range filtering functionality",
                "tagFiltering", "Tag-based filtering functionality", 
                "search", "Search by name and filename",
                "sorting", "Ascending/descending sort by createdAt"
            )
        );
        return ResponseEntity.ok(info);
    }
}
