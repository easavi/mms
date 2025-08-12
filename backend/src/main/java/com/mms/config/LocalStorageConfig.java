package com.mms.config;

import com.mms.service.LocalStorageService;
import com.mms.service.StorageService;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
@ConditionalOnProperty(name = "storage.type", havingValue = "local")
public class LocalStorageConfig {

    @Bean
    @Primary
    public StorageService storageService() {
        return new LocalStorageService();
    }
}
