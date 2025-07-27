package com.mms.controller;

import com.mms.service.DemoDataService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/demo")
public class DemoController {
    
    private final DemoDataService demoDataService;
    
    public DemoController(DemoDataService demoDataService) {
        this.demoDataService = demoDataService;
    }
    
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createDemoData() {
        Map<String, Object> result = demoDataService.createDemoData();
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/clear")
    public ResponseEntity<Map<String, Object>> clearDemoData() {
        Map<String, Object> result = demoDataService.clearDemoData();
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getDemoInfo() {
        Map<String, Object> info = Map.of(
            "title", "Demo Data Management",
            "description", "Create and manage demo data for testing the Media Management System",
            "endpoints", Map.of(
                "POST /api/demo/create", "Create demo data (users, tags, storages, media)",
                "POST /api/demo/clear", "Get info about clearing demo data",
                "GET /api/demo/info", "Get demo API information"
            ),
            "demoDataIncludes", Map.of(
                "users", "4 demo users with different roles",
                "tags", "10 common tags (vacation, work, family, etc.)",
                "storages", "2 storage configurations (AWS and Minio)",
                "media", "15 media items with varied dates and tag associations"
            )
        );
        return ResponseEntity.ok(info);
    }
}
