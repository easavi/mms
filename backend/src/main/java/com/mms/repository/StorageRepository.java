package com.mms.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.mms.entity.Storage;

public interface StorageRepository extends JpaRepository<Storage, UUID> {
    
    List<Storage> findByUsername(String username);
    
    List<Storage> findByUsernameAndDeviceId(String username, String deviceId);
    
    List<Storage> findByType(String type);
    
    List<Storage> findByUsernameAndType(String username, String type);
    
    Optional<Storage> findByUsernameAndPath(String username, String path);
    
    Optional<Storage> findByBucket(String bucket);
    
    @Query("SELECT s FROM Storage s WHERE s.username = :username ORDER BY s.updated DESC")
    List<Storage> findByUsernameOrderByUpdatedDesc(@Param("username") String username);
    
    @Query("SELECT s FROM Storage s WHERE s.username = :username AND s.deviceId = :deviceId ORDER BY s.updated DESC")
    List<Storage> findByUsernameAndDeviceIdOrderByUpdatedDesc(@Param("username") String username, @Param("deviceId") String deviceId);
    
    @Query("SELECT COUNT(s) FROM Storage s WHERE s.username = :username")
    long countByUsername(@Param("username") String username);
    
}
