@echo off
echo ===============================================
echo MMS Listener Application Test Script
echo ===============================================
echo.

echo Building the application...
cd /d "%~dp0"
call mvn clean package -DskipTests

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful!
echo.

echo Starting in LISTENER mode...
echo Make sure the MMS backend is running on http://localhost:8080
echo.
pause
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar

pause
