package com.mms.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

import java.util.Map;

@Getter
public class ValidationErrorResponse extends ErrorResponse {
    private final Map<String, String> errors;

    public ValidationErrorResponse(HttpStatus status, String message, Map<String, String> errors) {
        super(status, message);
        this.errors = errors;
    }
}
