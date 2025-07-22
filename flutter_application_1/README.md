# MyPathPal Flutter App

## Step-by-Step Setup Guide

### 1. Clone the Repository
Open your terminal or command prompt and run:
```sh
git clone https://github.com/julbien/MyPathPal-Flutter-App.git
cd MyPathPal-Flutter-App
```

### 2. Open the Project
- Open the project folder in your preferred IDE (VSCode, Android Studio, etc.)

---

### 3. If You Will Use an **External Android Device**
#### a. **Replace the IP Address in `api_config.dart`**
1. Open `lib/config/api_config.dart`.
2. On lines 3 and 4, you will see something like:
   ```dart
   static const String baseUrl = 'http://192.168.1.10:3000/api/auth';
   ```
3. **Find your computer's IP address:**
   - Open Command Prompt (Windows) or Terminal (Mac/Linux).
   - Type: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Look for your **IPv4 Address** (e.g., `192.168.1.10`).
4. **Copy your IPv4 address** and replace the IP in `baseUrl` so it matches your computer's IP.
5. Save the file.

---

### 4. If You Will Use **Google Chrome (Web)**
#### a. **Adjust the API URL for Web**
- Make sure your backend server is accessible from your browser (same network, firewall open on port 3000).
- You may need to use your computer's IP address in `api_config.dart` as above.
- If you want to test locally, you can use `localhost` or `127.0.0.1` if the backend is running on the same machine.

#### b. **Run the App for Web**
```sh
flutter run -d chrome
```

---

## 5. Backend Setup (Required Before Running Flutter App)
**Before running `flutter run`, make sure your backend is running!**

#### a. **Clone the Web App/Backend Repository**
```sh
git clone <your-backend-repo-url>
```

#### b. **Start XAMPP (Apache and MySQL)**
- Open XAMPP and click **Start** for both **Apache** and **MySQL**.

#### c. **Import the Database**
1. Go to your backend folder, then `scripts`.
2. Open `pathpal_db.sql`.
3. Copy the `CREATE DATABASE` statement and run it in phpMyAdmin or MySQL command line.
4. After creating the database, copy and run the table creation statements in the same way.

#### d. **Install Backend Dependencies and Create Admin**
1. Open a terminal in your backend folder.
2. Run:
   ```sh
   npm install
   npm install nodemailer
   ```
3. Create `admin.js` (follow your backend instructions to create an admin user).

#### e. **Run the Backend Server**
```sh
node backend/server.js
```

---

## 6. Install Flutter Dependencies and Run the App
```sh
flutter pub get
flutter run
```

---

## Troubleshooting
- Make sure your backend server is running and accessible from your device/browser.
- If you get network errors, double-check the IP address in `api_config.dart` and your firewall settings.
- For Android, enable developer mode and USB debugging on your device.

---


