package com.mms.service;

import com.mms.entity.Media;
import com.mms.entity.MediaType;
import com.mms.entity.Tag;
import com.mms.entity.User;
import com.mms.entity.Storage;
import com.mms.entity.StorageType;
import com.mms.repository.MediaRepository;
import com.mms.repository.TagRepository;
import com.mms.repository.UserRepository;
import com.mms.repository.StorageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.*;

@Service
public class DemoDataService {
    
    private final MediaRepository mediaRepository;
    private final TagRepository tagRepository;
    private final UserRepository userRepository;
    private final StorageRepository storageRepository;
    
    public DemoDataService(MediaRepository mediaRepository, TagRepository tagRepository,
                          UserRepository userRepository, StorageRepository storageRepository) {
        this.mediaRepository = mediaRepository;
        this.tagRepository = tagRepository;
        this.userRepository = userRepository;
        this.storageRepository = storageRepository;
    }
    
    @Transactional
    public Map<String, Object> createDemoData() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Create demo users
            List<User> users = createDemoUsers();
            result.put("users", users.size());
            
            // Create demo tags
            List<Tag> tags = createDemoTags();
            result.put("tags", tags.size());
            
            // Create demo storage
            List<Storage> storages = createDemoStorages(users);
            result.put("storages", storages.size());
            
            // Create demo media with various dates and tags
            List<Media> mediaItems = createDemoMedia(tags);
            result.put("media", mediaItems.size());
            
            result.put("status", "success");
            result.put("message", "Demo data created successfully");
            
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", "Error creating demo data: " + e.getMessage());
        }
        
        return result;
    }
    
    private List<User> createDemoUsers() {
        List<User> users = new ArrayList<>();
        
        String[] usernames = {"john_doe", "jane_smith", "admin_user", "test_user"};
        String[] emails = {"john@example.com", "jane@example.com", "admin@example.com", "test@example.com"};
        
        for (int i = 0; i < usernames.length; i++) {
            if (!userRepository.existsByUsername(usernames[i])) {
                User user = new User(usernames[i], "password123", emails[i]);
                users.add(userRepository.save(user));
            }
        }
        
        return users;
    }
    
    private List<Tag> createDemoTags() {
        List<Tag> tags = new ArrayList<>();
        
        String[] tagNames = {"vacation", "work", "family", "nature", "city", "food", "sports", "music", "art", "technology"};
        
        for (String tagName : tagNames) {
            if (!tagRepository.existsByName(tagName)) {
                Tag tag = new Tag(tagName);
                tags.add(tagRepository.save(tag));
            }
        }
        
        return tags;
    }
    
    private List<Storage> createDemoStorages(List<User> users) {
        List<Storage> storages = new ArrayList<>();
        
        if (!users.isEmpty()) {
            User user = users.get(0);
            
            // AWS Storage
            Storage awsStorage = new Storage(StorageType.AWS, "My AWS Bucket", "aws-media-bucket", user.getUsername());
            awsStorage.setSize(1000000L);
            awsStorage.setItemsQuantity(50);
            storages.add(storageRepository.save(awsStorage));
            
            // Minio Storage
            Storage minioStorage = new Storage(StorageType.Minio, "Local Minio", "minio-bucket", user.getUsername());
            minioStorage.setSize(500000L);
            minioStorage.setItemsQuantity(25);
            storages.add(storageRepository.save(minioStorage));
        }
        
        return storages;
    }
    
    private List<Media> createDemoMedia(List<Tag> tags) {
        List<Media> mediaItems = new ArrayList<>();
        Random random = new Random();
        
        String[] mediaNames = {
            "Summer Vacation Photo", "Team Meeting Recording", "Family Reunion",
            "Mountain Landscape", "City Skyline", "Delicious Dinner",
            "Football Game", "Concert Performance", "Art Gallery Visit",
            "Tech Conference Presentation", "Beach Sunset", "Office Party",
            "Birthday Celebration", "Hiking Adventure", "Cooking Tutorial"
        };
        
        String[] fileNames = {
            "summer_vacation.jpg", "team_meeting.mp4", "family_reunion.jpg",
            "mountain_landscape.jpg", "city_skyline.jpg", "dinner.jpg",
            "football_game.mp4", "concert.mp4", "art_gallery.jpg",
            "tech_presentation.pdf", "beach_sunset.jpg", "office_party.jpg",
            "birthday.jpg", "hiking.jpg", "cooking_tutorial.mp4"
        };
        
        MediaType[] mediaTypes = {MediaType.image, MediaType.video, MediaType.file};
        
        for (int i = 0; i < mediaNames.length; i++) {
            Media media = new Media();
            media.setName(mediaNames[i]);
            media.setFileName(fileNames[i]);
            media.setFileUrl("https://example.com/media/" + fileNames[i]);
            media.setMediaType(mediaTypes[random.nextInt(mediaTypes.length)]);
            
            // Set random dates over the past year
            OffsetDateTime baseDate = OffsetDateTime.now().minusMonths(12);
            OffsetDateTime createdAt = baseDate.plusDays(random.nextInt(365));
            media.setCreatedAt(createdAt);
            
            // Assign random tags (1-3 tags per media)
            Set<Tag> mediaTags = new HashSet<>();
            int tagCount = random.nextInt(3) + 1;
            for (int j = 0; j < tagCount; j++) {
                if (!tags.isEmpty()) {
                    Tag randomTag = tags.get(random.nextInt(tags.size()));
                    mediaTags.add(randomTag);
                }
            }
            media.setTags(mediaTags);
            
            mediaItems.add(mediaRepository.save(media));
        }
        
        return mediaItems;
    }
    
    @Transactional
    public Map<String, Object> clearDemoData() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            long mediaCount = mediaRepository.count();
            long tagCount = tagRepository.count();
            long storageCount = storageRepository.count();
            long userCount = userRepository.count();
            
            // Note: In a real application, you'd want to be more careful about deletion
            // This is just for demo purposes
            
            result.put("beforeDeletion", Map.of(
                "media", mediaCount,
                "tags", tagCount,
                "storages", storageCount,
                "users", userCount
            ));
            
            result.put("status", "success");
            result.put("message", "Demo data clearing info retrieved (deletion not implemented for safety)");
            
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", "Error clearing demo data: " + e.getMessage());
        }
        
        return result;
    }
}
