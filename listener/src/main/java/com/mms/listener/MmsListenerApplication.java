package com.mms.listener;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class MmsListenerApplication {

    public static void main(String[] args) {
        // Check for operation mode parameter
        String mode = "listener"; // default mode
        
        for (String arg : args) {
            if (arg.startsWith("--mode=")) {
                mode = arg.substring(7);
                break;
            }
        }
        
        System.setProperty("mms.operation.mode", mode);
        System.out.println("Starting MMS Listener Application in mode: " + mode);
        
        SpringApplication.run(MmsListenerApplication.class, args);
    }
}
