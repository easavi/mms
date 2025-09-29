package com.mms.repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
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
    
    // Combined filters: media type + date range
    @Query("SELECT m FROM Media m WHERE m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt DESC")
    Page<Media> findByMediaTypeAndCreatedAtBetweenOrderByCreatedAtDesc(
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    @Query("SELECT m FROM Media m WHERE m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt ASC")
    Page<Media> findByMediaTypeAndCreatedAtBetweenOrderByCreatedAtAsc(
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    // Combined filters: media type + tags
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.mediaType = :mediaType AND t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByMediaTypeAndTagsNameInOrderByCreatedAtDesc(
        @Param("mediaType") String mediaType,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.mediaType = :mediaType AND t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByMediaTypeAndTagsNameInOrderByCreatedAtAsc(
        @Param("mediaType") String mediaType,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // Combined filters: media type + date range + tags
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
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
    
    // Storage-related queries
    @Query("SELECT COUNT(m) FROM Media m WHERE m.storageId = :storageId")
    Integer countByStorageId(@Param("storageId") String storageId);
    
    @Query("SELECT COALESCE(SUM(m.fileSize), 0) FROM Media m WHERE m.storageId = :storageId")
    Long sumFileSizesByStorageId(@Param("storageId") String storageId);
    
    @Query("SELECT m FROM Media m WHERE m.storageId = :storageId")
    List<Media> findByStorageId(@Param("storageId") String storageId);
    
    // Find media by file hash
    @Query("SELECT m FROM Media m WHERE m.fileHash = :fileHash")
    Optional<Media> findByFileHash(@Param("fileHash") String fileHash);
    
    // User-filtered queries
    Page<Media> findByUsernameOrderByCreatedAtDesc(String username, Pageable pageable);
    Page<Media> findByUsernameOrderByCreatedAtAsc(String username, Pageable pageable);
    
    // User + type filter
    Page<Media> findByUsernameAndMediaTypeOrderByCreatedAtDesc(String username, String mediaType, Pageable pageable);
    Page<Media> findByUsernameAndMediaTypeOrderByCreatedAtAsc(String username, String mediaType, Pageable pageable);
    
    // User + date range filter
    @Query("SELECT m FROM Media m WHERE m.username = :username AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndCreatedAtBetweenOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    @Query("SELECT m FROM Media m WHERE m.username = :username AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndCreatedAtBetweenOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    // User + tags filter
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndTagsNameInOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndTagsNameInOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // User + type + date range filter
    @Query("SELECT m FROM Media m WHERE m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndMediaTypeAndCreatedAtBetweenOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    @Query("SELECT m FROM Media m WHERE m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndMediaTypeAndCreatedAtBetweenOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        Pageable pageable
    );
    
    // User + type + tags filter
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndMediaTypeAndTagsNameInOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndMediaTypeAndTagsNameInOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // User + date range + tags filter
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // User + type + date range + tags filter (full combination)
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt DESC")
    Page<Media> findByUsernameAndMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtDesc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    @Query("SELECT DISTINCT m FROM Media m JOIN m.tags t WHERE " +
           "m.username = :username AND " +
           "m.mediaType = :mediaType AND " +
           "m.createdAt BETWEEN :startDate AND :endDate AND " +
           "t.name IN :tagNames ORDER BY m.createdAt ASC")
    Page<Media> findByUsernameAndMediaTypeAndCreatedAtBetweenAndTagsNameInOrderByCreatedAtAsc(
        @Param("username") String username,
        @Param("mediaType") String mediaType,
        @Param("startDate") OffsetDateTime startDate,
        @Param("endDate") OffsetDateTime endDate,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );
    
    // User-specific basic queries
    List<Media> findByUsername(String username);
    Optional<Media> findByIdAndUsername(UUID id, String username);
    
    // User-specific file hash query
    @Query("SELECT m FROM Media m WHERE m.fileHash = :fileHash AND m.username = :username")
    Optional<Media> findByFileHashAndUsername(@Param("fileHash") String fileHash, @Param("username") String username);
}
