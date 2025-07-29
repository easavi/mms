package com.mms.service;

import com.mms.repository.MediaRepository;
import com.mms.repository.TagRepository;
import com.mms.repository.StorageRepository;
import com.mms.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ValidationService {
    
    private final MediaRepository mediaRepository;
    private final TagRepository tagRepository;
    private final StorageRepository storageRepository;
    private final UserRepository userRepository;
    
    public ValidationService(MediaRepository mediaRepository, TagRepository tagRepository,
                           StorageRepository storageRepository, UserRepository userRepository) {
        this.mediaRepository = mediaRepository;
        this.tagRepository = tagRepository;
        this.storageRepository = storageRepository;
        this.userRepository = userRepository;
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> validateSystemHealth() {
        Map<String, Object> health = new HashMap<>();
        
        try {
            // Check database connectivity and basic operations
            long mediaCount = mediaRepository.count();
            long tagCount = tagRepository.count();
            long storageCount = storageRepository.count();
            long userCount = userRepository.count();
            
            health.put("status", "healthy");
            health.put("counts", Map.of(
                "media", mediaCount,
                "tags", tagCount,
                "storages", storageCount,
                "users", userCount
            ));
            
            // Test grouping queries
            try {
                List<Object[]> monthlyStats = mediaRepository.getMediaCountGroupedByMonth();
                List<Object[]> dailyStats = mediaRepository.getMediaCountGroupedByDay();
                List<Object[]> tagStats = mediaRepository.getMediaCountGroupedByTag();
                
                health.put("groupingQueries", Map.of(
                    "monthlyGroups", monthlyStats.size(),
                    "dailyGroups", dailyStats.size(),
                    "tagGroups", tagStats.size()
                ));
            } catch (Exception e) {
                health.put("groupingQueries", "error: " + e.getMessage());
            }
            
            // Test repository methods
            Map<String, String> repositoryTests = new HashMap<>();
            
            try {
                tagRepository.findAllTagNames();
                repositoryTests.put("tagRepository", "ok");
            } catch (Exception e) {
                repositoryTests.put("tagRepository", "error: " + e.getMessage());
            }
                        
            health.put("repositoryTests", repositoryTests);
            
        } catch (Exception e) {
            health.put("status", "error");
            health.put("error", e.getMessage());
        }
        
        return health;
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> validateAdvancedFeatures() {
        Map<String, Object> validation = new HashMap<>();
        
        try {
            // Test advanced media filtering
            Map<String, String> featureTests = new HashMap<>();
            
            // Test date range filtering
            try {
                mediaRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(
                    java.time.OffsetDateTime.now().minusMonths(1),
                    java.time.OffsetDateTime.now(),
                    org.springframework.data.domain.PageRequest.of(0, 10)
                );
                featureTests.put("dateRangeFiltering", "ok");
            } catch (Exception e) {
                featureTests.put("dateRangeFiltering", "error: " + e.getMessage());
            }
            
            // Test tag filtering
            try {
                List<String> testTags = List.of("test");
                mediaRepository.findByTagsNameInOrderByCreatedAtDesc(
                    testTags,
                    org.springframework.data.domain.PageRequest.of(0, 10)
                );
                featureTests.put("tagFiltering", "ok");
            } catch (Exception e) {
                featureTests.put("tagFiltering", "error: " + e.getMessage());
            }
            
            // Test search functionality
            try {
                mediaRepository.searchByNameOrFileName(
                    "test",
                    org.springframework.data.domain.PageRequest.of(0, 10)
                );
                featureTests.put("searchFunctionality", "ok");
            } catch (Exception e) {
                featureTests.put("searchFunctionality", "error: " + e.getMessage());
            }
            
            validation.put("status", "tested");
            validation.put("featureTests", featureTests);
            
        } catch (Exception e) {
            validation.put("status", "error");
            validation.put("error", e.getMessage());
        }
        
        return validation;
    }
}
