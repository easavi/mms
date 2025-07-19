package com.mms.exception;

import org.springframework.http.HttpStatus;

public class ErrorResponse {
    private final int status;
    private final String message;
    private final String timestamp;

    public ErrorResponse(HttpStatus status, String message) {
        this.status = status.value();
        this.message = message;
        this.timestamp = java.time.OffsetDateTime.now().toString();
    }

    public int getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public String getTimestamp() {
        return timestamp;
    }
}
