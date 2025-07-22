MyPathPal Mobile App – Setup & Access Guide
===========================================

Project Structure:
---------------------
mypathpal-mobile/
├── backend/                - Node.js/Express AP
└── flutter_application_1/  - Flutter mobile app project

Backend & Database Info:
----------------------------
- Backend is deployed using Render.
- Database is hosted on Hostinger (MySQL).
- Deployed Backend URL: https://mobile-backend-tt6t.onrender.com

Option 1: Install the APK (Recommended for Users)
-----------------------------------------------------
1. Download the APK from this link:
   https://drive.google.com/drive/folders/1REHwViqvHUKE1lfhn47bSsDzZfPmFmED

2. On your Android device:
   - Open the link and download the APK file.
   - Tap the file and install it.
   - If prompted, allow installation from unknown sources.

3. Open the app and use it normally.

Option 2: Run the Flutter App Locally (For Developers)
----------------------------------------------------------
Requirements:
- Flutter SDK installed
- Android Studio or VS Code (with Flutter plugin)
- Android emulator or a physical Android device with:
  - Developer Mode enabled
  - USB Debugging turned on

Steps:
1. Clone the repository:
   git clone https://github.com/julbien/mobile-backend.git

2. Navigate into the Flutter app folder:
   cd mypathpal-mobile/flutter_application_1

3. Get all dependencies:
   flutter pub get

4. Run the app:
   flutter run

Run Backend Locally:
1. Open a new terminal and go to the backend folder:
   cd mypathpal-mobile/backend

2. Install backend dependencies:
   npm install

3. Start the backend server:
   node server.js

4. Find your local IPv4 address:
   - Open Command Prompt
   - Type: ipconfig
   - Look for “IPv4 Address” (ex. 192.168.1.5)

5. In Flutter app (api_config.dart), replace the URL:
   From:
   https://mobile-backend-tt6t.onrender.com  
   To:
   http://<your-ipv4-address>:3000

   Example:
   http://192.168.1.5:3000

IMPORTANT:
-------------
- Your laptop and Android phone must be connected to the SAME Wi-Fi network.
- Restart the app after changing the API URL.

Notes:
---------
- All data is synced to the live database on Hostinger.
- Use the deployed backend for production or testing without running the backend locally.
