package com.mms.listener.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@ConfigurationProperties(prefix = "mms")
public class MmsConfig {

    private Backend backend = new Backend();
    private List<String> folders;
    private List<FolderCopyMapping> folderCopyMappings;
    private FilePatterns filePatterns = new FilePatterns();

    public static class Backend {
        private String url;
        private String username;
        private String password;

        // Getters and setters
        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }

    public static class FolderCopyMapping {
        private String source;
        private String destination;

        // Constructors
        public FolderCopyMapping() {}

        public FolderCopyMapping(String source, String destination) {
            this.source = source;
            this.destination = destination;
        }

        // Getters and setters
        public String getSource() {
            return source;
        }

        public void setSource(String source) {
            this.source = source;
        }

        public String getDestination() {
            return destination;
        }

        public void setDestination(String destination) {
            this.destination = destination;
        }

        @Override
        public String toString() {
            return source + " -> " + destination;
        }
    }

    public static class FilePatterns {
        private String include;
        private String exclude;

        // Getters and setters
        public String getInclude() {
            return include;
        }

        public void setInclude(String include) {
            this.include = include;
        }

        public String getExclude() {
            return exclude;
        }

        public void setExclude(String exclude) {
            this.exclude = exclude;
        }
    }

    // Main getters and setters
    public Backend getBackend() {
        return backend;
    }

    public void setBackend(Backend backend) {
        this.backend = backend;
    }

    public List<String> getFolders() {
        return folders;
    }

    public void setFolders(List<String> folders) {
        this.folders = folders;
    }

    public List<FolderCopyMapping> getFolderCopyMappings() {
        return folderCopyMappings;
    }

    public void setFolderCopyMappings(List<FolderCopyMapping> folderCopyMappings) {
        this.folderCopyMappings = folderCopyMappings;
    }

    public FilePatterns getFilePatterns() {
        return filePatterns;
    }

    public void setFilePatterns(FilePatterns filePatterns) {
        this.filePatterns = filePatterns;
    }
}
