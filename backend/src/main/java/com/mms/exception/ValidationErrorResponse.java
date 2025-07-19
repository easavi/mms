package com.mms.exception;

import org.springframework.http.HttpStatus;

import java.util.Map;

public class ValidationErrorResponse extends ErrorResponse {
    private final Map<String, String> errors;

    public ValidationErrorResponse(HttpStatus status, String message, Map<String, String> errors) {
        super(status, message);
        this.errors = errors;
    }

    public Map<String, String> getErrors() {
        return errors;
    }
}
