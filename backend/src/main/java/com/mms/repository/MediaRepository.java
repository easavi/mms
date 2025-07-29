package com.mms.repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.mms.entity.Media;

public interface MediaRepository extends JpaRepository<Media, UUID> {
    
    // Basic queries
    Page<Media> findAllByOrderByCreatedAtDesc(Pageable pageable);
    
    Page<Media> findAllByOrderByCreatedAtAsc(Pageable pageable);
    
    // Filter by media type
    Page<Media> findByMediaTypeOrderByCreatedAtDesc(String mediaType, Pageable pageable);
    
    Page<Media> findByMediaTypeOrderByCreatedAtAsc(String mediaType, Pageable pageable);
    
    // Filter by date range
    @Query("SELECT m FROM Media m WHERE m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt DESC")
    Page<Media> findByCreatedAtBetweenOrderByCreatedAtDesc(
        @Param("startDate") OffsetDateTime startDate, 
        @Param("endDate") OffsetDateTime endDate, 
        Pageable pageable
    );
    
    @Query("SELECT m FROM Media m WHERE m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt ASC")
    Page<Media> findByCreatedAtBetweenOrderByCreatedAtAsc(
        @Param("startDate") OffsetDateTime startDate, 
        @Param("endDate") OffsetDateTime endDate, 
        Pageable pageable
    );
    
    // Filter by tags
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByTagsNameInOrderByCreatedAtDesc(@Param("tagNames") List<String> tagNames, Pageable pageable);
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByTagsNameInOrderByCreatedAtAsc(@Param("tagNames") List<String> tagNames, Pageable pageable);
    
    // Combined filters: date range + tags
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // Grouping queries for month/day aggregation
    @Query("SELECT FUNCTION('DATE_TRUNC', 'month', m.createdAt) as period, COUNT(m) as count " +
           "FROM Media m GROUP BY FUNCTION('DATE_TRUNC', 'month', m.createdAt) " +
           "ORDER BY period DESC")
    List<Object[]> getMediaCountGroupedByMonth();
    
    @Query("SELECT FUNCTION('DATE_TRUNC', 'day', m.createdAt) as period, COUNT(m) as count " +
           "FROM Media m GROUP BY FUNCTION('DATE_TRUNC', 'day', m.createdAt) " +
           "ORDER BY period DESC")
    List<Object[]> getMediaCountGroupedByDay();
    
    // Grouping by tag
    @Query("SELECT t.name as tagName, COUNT(m) as count " +
           "FROM Media m JOIN m.tags t GROUP BY t.name ORDER BY count DESC")
    List<Object[]> getMediaCountGroupedByTag();
    
    // Search functionality
    @Query("SELECT m FROM Media m WHERE " +
           "LOWER(m.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(m.fileName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Media> searchByNameOrFileName(@Param("searchTerm") String searchTerm, Pageable pageable);
}
