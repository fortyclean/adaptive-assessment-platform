@echo off
title Adaptive Assessment Platform - Launcher
color 0A

echo ============================================
echo   Adaptive Assessment Platform Launcher
echo ============================================
echo.

:: ─── Get local IP ────────────────────────────────────────────────────────────
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "169\." ^| findstr /v "172\."') do (
    set LOCAL_IP=%%a
    goto :found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP: =%
echo [INFO] Local IP: %LOCAL_IP%

:: ─── Kill any existing node on port 3000 ─────────────────────────────────────
echo [INFO] Stopping any existing server on port 3000...
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":3000 " ^| findstr LISTENING') do (
    taskkill /PID %%a /F >nul 2>&1
)

:: ─── Start MongoDB + Redis via Docker ────────────────────────────────────────
echo [INFO] Starting MongoDB and Redis...
docker compose up mongodb redis -d >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Docker not available or already running - continuing...
)
timeout /t 3 /nobreak >nul

:: ─── Build backend if dist doesn't exist ─────────────────────────────────────
if not exist "backend\dist\app.js" (
    echo [INFO] Building backend...
    cd backend
    call node node_modules/typescript/bin/tsc >nul 2>&1
    cd ..
)

:: ─── Seed database ────────────────────────────────────────────────────────────
echo [INFO] Seeding database (creating default users if needed)...
cd backend
node scripts/seed.js 2>nul
cd ..

:: ─── Start backend server ────────────────────────────────────────────────────
echo [INFO] Starting backend server on port 3000...
start "Backend Server" cmd /k "cd /d %~dp0backend && node dist/app.js"
timeout /t 3 /nobreak >nul

:: ─── Build Flutter APK with correct IP ───────────────────────────────────────
echo.
echo [INFO] Building Flutter APK with API URL: http://%LOCAL_IP%:3000/api/v1
echo [INFO] This may take a few minutes...
echo.

cd mobile
call C:\flutter\bin\flutter.bat build apk --debug "--dart-define=API_URL=http://%LOCAL_IP%:3000/api/v1" 2>&1
cd ..

if exist "mobile\build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ============================================
    echo   SUCCESS!
    echo ============================================
    echo.
    echo Backend:  http://%LOCAL_IP%:3000/api/v1
    echo APK:      mobile\build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo Default accounts:
    echo   Admin:   admin / Admin@1234
    echo   Teacher: teacher1 / Teacher@1234
    echo   Student: student1 / Student@1234
    echo.
    echo Install APK on your phone and connect to the same WiFi network.
    echo.
    
    :: Open APK folder
    explorer "mobile\build\app\outputs\flutter-apk\"
) else (
    echo.
    echo [ERROR] Build failed. Check the output above for errors.
)

pause
