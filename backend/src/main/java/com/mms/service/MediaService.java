package com.mms.service;

import com.mms.dto.media.MediaResponse;
import com.mms.dto.media.MediaUploadRequest;
import com.mms.entity.MediaItem;
import com.mms.entity.Tag;
import com.mms.entity.User;
import com.mms.exception.ApiException;
import com.mms.repository.MediaItemRepository;
import com.mms.repository.TagRepository;
import com.mms.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MediaService {
    private final MediaItemRepository mediaItemRepository;
    private final UserRepository userRepository;
    private final TagRepository tagRepository;
    private final StorageService storageService;
    
    public MediaService(
            MediaItemRepository mediaItemRepository,
            UserRepository userRepository,
            TagRepository tagRepository,
            StorageService storageService) {
        this.mediaItemRepository = mediaItemRepository;
        this.userRepository = userRepository;
        this.tagRepository = tagRepository;
        this.storageService = storageService;
    }

    @Transactional
    public MediaResponse uploadMedia(MediaUploadRequest request, UserDetails userDetails) {
        User user = userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));

        String originalFilename = StringUtils.cleanPath(request.getFile().getOriginalFilename());
        String storageKey = generateStorageKey(user.getId(), originalFilename);
        
        String storedPath = storageService.store(request.getFile(), storageKey);
        
        Set<Tag> tags = processTags(request.getTags());

        MediaItem mediaItem = new MediaItem();
        mediaItem.setUser(user);
        mediaItem.setTitle(request.getTitle());
        mediaItem.setDescription(request.getDescription());
        mediaItem.setMediaType(request.getMediaType());
        mediaItem.setFilePath(storedPath);
        mediaItem.setMimeType(request.getFile().getContentType());
        mediaItem.setFileSize(request.getFile().getSize());
        mediaItem.setOriginalFilename(originalFilename);
        mediaItem.setTags(tags);

        mediaItem = mediaItemRepository.save(mediaItem);
        
        return convertToResponse(mediaItem);
    }

    @Transactional(readOnly = true)
    public Page<MediaResponse> getAllMedia(String searchTerm, String mediaType, Pageable pageable) {
        Page<MediaItem> mediaItems;
        
        if (StringUtils.hasText(searchTerm)) {
            mediaItems = mediaItemRepository.search(
                    mediaType != null ? com.mms.entity.MediaType.valueOf(mediaType.toUpperCase()) : null,
                    searchTerm,
                    pageable
            );
        } else {
            mediaItems = mediaItemRepository.findAll(pageable);
        }

        return mediaItems.map(this::convertToResponse);
    }

    @Transactional(readOnly = true)
    public MediaResponse getMediaById(UUID id) {
        MediaItem mediaItem = mediaItemRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Media not found"));
        
        return convertToResponse(mediaItem);
    }

    private Set<Tag> processTags(String[] tagNames) {
        if (tagNames == null || tagNames.length == 0) {
            return new HashSet<>();
        }

        return Arrays.stream(tagNames)
                .map(name -> tagRepository.findByNameIgnoreCase(name)
                        .orElseGet(() -> {
                            Tag tag = new Tag();
                            tag.setName(name.toLowerCase());
                            return tagRepository.save(tag);
                        }))
                .collect(Collectors.toSet());
    }

    private String generateStorageKey(UUID userId, String filename) {
        return String.format("%s/%s/%s", userId.toString().substring(0, 2), userId, filename);
    }

    private MediaResponse convertToResponse(MediaItem mediaItem) {
        MediaResponse response = new MediaResponse();
        response.setId(mediaItem.getId().toString());
        response.setTitle(mediaItem.getTitle());
        response.setDescription(mediaItem.getDescription());
        response.setMediaType(mediaItem.getMediaType());
        response.setUrl(storageService.getUrl(mediaItem.getFilePath()));
        response.setTags(mediaItem.getTags().stream()
                .map(Tag::getName)
                .toArray(String[]::new));
        response.setCreatedAt(mediaItem.getCreatedAt().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        response.setUsername(mediaItem.getUser().getUsername());
        return response;
    }
}
