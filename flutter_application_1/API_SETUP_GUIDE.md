# Flutter Mobile App - Database Connection Setup Guide

## Overview
This guide explains how to connect your Flutter mobile app to the same database as your web application.

## Prerequisites
- Flutter app running
- Web app with API endpoints running
- Both apps should be on the same network (for local development)

## Step 1: Configure API Settings

### For Android Emulator:
1. Open `lib/config/api_config.dart`
2. Make sure the baseUrl is set to:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   ```

### For Physical Device:
1. Find your computer's IP address:
   - Windows: Run `ipconfig` in CMD
   - Mac/Linux: Run `ifconfig` in Terminal
2. Update `lib/config/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
   ```
   Example: `http://192.168.1.100:3000/api`

## Step 2: Web App API Requirements

Your web app should have these API endpoints:

### POST /api/auth/signup
**Request Body:**
```json
{
  "username": "string",
  "email": "string",
  "phoneNumber": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string",
    "phoneNumber": "string"
  }
}
```

### POST /api/auth/signin
**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string",
    "phoneNumber": "string"
  }
}
```

### GET /api/user/profile
**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string",
    "phoneNumber": "string"
  }
}
```

## Step 3: Install Dependencies

Run this command in your Flutter project directory:
```bash
flutter pub get
```

## Step 4: Test the Connection

1. Make sure your web app is running
2. Run your Flutter app
3. Try to sign up with a new account
4. Check if the user appears in your web app's database

## Step 5: Troubleshooting

### Common Issues:

1. **Connection refused error:**
   - Make sure your web app is running
   - Check if the port number is correct
   - Verify the IP address is correct

2. **CORS errors (if testing on web):**
   - Add CORS headers to your web app
   - Allow requests from your Flutter app's origin

3. **Timeout errors:**
   - Check your internet connection
   - Verify the API endpoints are working
   - Increase timeout in `api_config.dart` if needed

### Testing API Endpoints:

You can test your API endpoints using tools like:
- Postman
- cURL
- Browser (for GET requests)

Example cURL command:
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","phoneNumber":"1234567890","password":"password123"}'
```

## Step 6: Security Considerations

1. **HTTPS in Production:**
   - Always use HTTPS in production
   - Update the baseUrl to use `https://`

2. **Token Storage:**
   - Tokens are stored locally using SharedPreferences
   - Consider additional encryption for sensitive data

3. **Input Validation:**
   - The app includes basic validation
   - Ensure your web app also validates all inputs

## Step 7: Database Schema

Make sure your database has a users table with these fields:
- id (primary key)
- username
- email (unique)
- phone_number
- password (hashed)
- created_at
- updated_at

## Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify your web app API endpoints are working
3. Test the connection using Postman or similar tools
4. Ensure both apps are on the same network 