# Build stage
FROM eclipse-temurin:24-jdk-alpine as build
WORKDIR /workspace/app

# Copy maven files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Build application
RUN chmod +x ./mvnw
RUN ./mvnw install -DskipTests

# Runtime stage
FROM eclipse-temurin:24-jre-alpine
VOLUME /tmp

# Add system user
RUN addgroup -S spring && adduser -S spring -G spring

# Copy build artifact from build stage
COPY --from=build /workspace/app/target/*.jar app.jar

# Set ownership
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring:spring

# Set entrypoint
ENTRYPOINT ["java", "-jar", "/app.jar"]
