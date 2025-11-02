# Complete Android Emulator and App Setup Guide for Kapok

This guide will walk you through **everything** you need to get the Kapok app running on an Android emulator, from initial setup to running the app.

---

## 📋 Table of Contents

1. [Pre-requisites](#pre-requisites)
2. [Install Android Studio](#install-android-studio)
3. [Configure Flutter](#configure-flutter)
4. [Create Android Emulator](#create-android-emulator)
5. [Run the Kapok App](#run-the-kapok-app)
6. [Troubleshooting](#troubleshooting)

---

## Pre-requisites

✅ **Windows 10/11** (you have this!)  
✅ **Flutter installed** (you have this!)  
✅ **Visual Studio Code or Android Studio**

---

## Install Android Studio

### Step 1: Download Android Studio

1. Go to: **https://developer.android.com/studio**
2. Click the big green **"Download Android Studio"** button
3. This will download `android-studio-xxxxx-windows.exe` (about 1GB)

### Step 2: Run the Installer

1. **Double-click** the downloaded `.exe` file
2. Click **"Next"** through the welcome screen
3. **Choose Components**: Make sure ALL boxes are checked:
   - ✓ Android SDK
   - ✓ Android SDK Platform
   - ✓ Android Virtual Device
   - ✓ Performance (Intel HAXM)
4. Click **"Next"**
5. **Installation Location**: Use default (`C:\Program Files\Android\Android Studio`)
6. Click **"Next"**
7. Accept the license agreement
8. Click **"Next"** → **"Install"**
9. Wait 5-10 minutes for installation
10. Click **"Finish"**

### Step 3: First Launch Setup

1. **Import Settings**: Choose **"Do not import settings"** → **OK**
2. **Welcome Screen**: Click **"Next"** (3 times)
3. **Download SDK**: Android Studio will now download:
   - Android SDK Platform
   - Android SDK Build-Tools
   - Platform Tools
   - Emulator System Images
   - **⏱️ This takes 20-40 minutes! Be patient.**
4. Click **"Finish"** when done

Android Studio main window should now be open!

---

## Configure Flutter

### Step 1: Open Terminal in Kapok Project

Navigate to your project:

```powershell
cd C:\Users\sonny\Desktop\kapok\Kapok\app
```

### Step 2: Configure Flutter for Android

```powershell
flutter doctor -v
```

This will show you what's missing. You should see:

```
✓ Android toolchain - develop for Android devices
✓ Android Studio (version 2025.x)
```

If you see **"Android SDK not found"**, run:

```powershell
flutter config --android-sdk "C:\Users\YourName\AppData\Local\Android\Sdk"
```

(Replace `YourName` with your Windows username)

### Step 3: Accept Android Licenses

```powershell
flutter doctor --android-licenses
```

Press `y` and Enter for each license (about 5-10 times).

### Step 4: Verify Setup

```powershell
flutter doctor
```

You should now see all ✓ green checkmarks for Android!

---

## Create Android Emulator

### Method 1: Using Android Studio GUI (Recommended)

1. **Open Android Studio** (the IDE)
2. **Device Manager**:
   - Click "Tools" in the menu bar → "Device Manager"
   - Or click the phone icon in the toolbar
3. **Create Device**:
   - Click the **"Create Device"** button
4. **Choose Device**:
   - Select **"Medium Phone API 36.1"** (or any phone)
   - Click **"Next"**
5. **Download System Image**:
   - If you see a **"Download"** link, click it
   - Wait for the system image to download (5-10 minutes)
   - Click **"Next"** when done
6. **Finish**:
   - Keep the default name or customize
   - Click **"Finish"**

Your emulator is now created! 🎉

### Method 2: Using Command Line

```powershell
flutter emulators --create --name kapok_emulator
```

---

## Run the Kapok App

### Quick Start Commands

**In your terminal (PowerShell), run these in order:**

```powershell
# 1. Navigate to app directory
cd C:\Users\sonny\Desktop\kapok\Kapok\app

# 2. Launch the emulator
flutter emulators --launch Medium_Phone_API_36.1

# 3. Wait 60 seconds for emulator to boot
Start-Sleep -Seconds 60

# 4. Check emulator is connected
flutter devices

# 5. Run the app!
flutter run -d emulator-5554
```

### What You Should See

1. **Emulator Window Opens**: Large phone screen appears
2. **Android Boots**: You see Android logo, then home screen
3. **Flutter Build**: Terminal shows "Building app..." (takes 2-5 minutes first time)
4. **App Installs**: "Installing app-debug.apk..."
5. **App Launches**: Kapok login screen appears on emulator!

### Login to Test

- **Email**: `test@gmail.com`
- **Password**: Your Firebase password
- Click **"Sign In"**

You'll see the main dashboard with Map, Tasks, Teams, Profile tabs!

---

## Troubleshooting

### ❌ "Android SDK not found"

**Fix:**

```powershell
flutter config --android-sdk "C:\Users\YourName\AppData\Local\Android\Sdk"
```

Then restart terminal.

### ❌ "No emulator found"

**Fix:** Launch emulator first:

```powershell
flutter emulators --launch Medium_Phone_API_36.1
Wait 60 seconds
flutter run -d emulator-5554
```

### ❌ "Google Services error"

**Fix:** The `google-services.json` file is already created. If missing:

```powershell
# Verify file exists
Test-Path android\app\google-services.json
# Should return: True
```

### ❌ "Emulator stuck at boot"

**Fix:**

1. Close emulator completely
2. In Android Studio: Tools → Device Manager
3. Click ⋮ (three dots) next to your emulator → "Wipe Data"
4. Launch again with `flutter emulators --launch Medium_Phone_API_36.1`

### ❌ "App crashes on launch"

**Fix:** Check emulator has enough RAM:

1. Android Studio → Device Manager
2. Click ⋮ (three dots) → "Edit"
3. Increase RAM to at least **2GB**
4. Save and restart

### ❌ "Multiple hero tags error" (Already Fixed!)

The FloatingActionButton duplicate error is already fixed in the code. If you still see it, just press `r` in terminal for hot reload.

### ❌ "Slow performance"

**Fix:** Enable hardware acceleration:

1. Android Studio → Device Manager
2. Click ⋮ (three dots) → "Edit"
3. Click "Show Advanced Settings"
4. Set Graphics: **Hardware - GLES 2.0**
5. Save and restart

---

## Common Commands Reference

```powershell
# Check setup
flutter doctor -v

# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# List connected devices
flutter devices

# Run app on emulator
flutter run -d emulator-5554

# While app is running:
#   r = Hot reload (apply changes without restart)
#   R = Hot restart (restart app keeping state)
#   q = Quit app and exit

# Clean build (if having issues)
flutter clean
flutter pub get
flutter run -d emulator-5554
```

---

## Expected Time Estimates

| Task                        | Time         |
| --------------------------- | ------------ |
| Download Android Studio     | 5-10 min     |
| Install Android Studio      | 5-10 min     |
| First Launch & SDK Download | 20-40 min ⏱️ |
| Create Emulator             | 2-5 min      |
| Launch Emulator             | 30-60 sec    |
| First App Build             | 3-5 min      |
| Subsequent Builds           | 30-60 sec    |

**Total First-Time Setup**: ~45-75 minutes (mostly waiting for downloads)

---

## Current Project Status

✅ **Already Done:**

- Android permissions configured
- Mapbox dependencies installed
- Google Services JSON created
- FloatingActionButton issues fixed
- emulator created and working

🔄 **Next Steps:**

1. Get Mapbox access token from https://mapbox.com
2. Add token to `android/app/src/main/AndroidManifest.xml`
3. Implement Mapbox widget in MapPage
4. Add offline map download functionality

---

## Need Help?

- **Android Studio won't open**: Restart computer, try again
- **Downloads too slow**: Check internet connection
- **Out of disk space**: Need at least 10GB free
- **Still stuck**: Delete everything, restart from beginning

### Useful Links

- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/windows)
- [Android Studio Docs](https://developer.android.com/studio/intro)
- [Mapbox Flutter Docs](https://github.com/tobrun/flutter-mapbox-gl)
- [Kapok Project Documentation](docs/)

---

## Success Checklist

- [ ] Android Studio installed
- [ ] Flutter doctor shows all green checkmarks
- [ ] Android licenses accepted
- [ ] Emulator created
- [ ] Emulator boots successfully
- [ ] App runs on emulator
- [ ] Login works
- [ ] Map page visible

**Once all checked, you're ready to build the map features!** 🗺️

---

**Last Updated**: November 2, 2025  
**Project**: Kapok Disaster Relief Coordination App  
**Platform**: Flutter with Android Emulator
