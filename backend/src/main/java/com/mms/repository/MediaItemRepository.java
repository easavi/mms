package com.mms.repository;

import com.mms.entity.MediaItem;
import com.mms.entity.MediaType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface MediaItemRepository extends JpaRepository<MediaItem, UUID> {
    Page<MediaItem> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    
    Page<MediaItem> findByMediaTypeOrderByCreatedAtDesc(MediaType mediaType, Pageable pageable);
    
    @Query("SELECT m FROM MediaItem m WHERE " +
           "(:mediaType IS NULL OR m.mediaType = :mediaType) AND " +
           "(LOWER(m.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(m.description) LIKE LOWER(CONCAT('%', :searchTerm, '%')))")
    Page<MediaItem> search(
        @Param("mediaType") MediaType mediaType,
        @Param("searchTerm") String searchTerm,
        Pageable pageable
    );
}
