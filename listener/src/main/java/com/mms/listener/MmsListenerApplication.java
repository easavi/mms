package com.mms.listener;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication(exclude = {WebMvcAutoConfiguration.class})
@EnableAsync
public class MmsListenerApplication {

    public static void main(String[] args) {
        // Disable web environment - this is a console application
        System.setProperty("spring.main.web-application-type", "none");
        
        SpringApplication app = new SpringApplication(MmsListenerApplication.class);
        app.setWebApplicationType(org.springframework.boot.WebApplicationType.NONE);
        app.run(args);
    }
}
