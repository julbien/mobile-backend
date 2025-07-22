# Mobile App Setup Guide

## Overview
This guide will help you connect your Flutter mobile app to your existing web app's database for seamless sign up and sign in functionality.

## Prerequisites
- Your web app is running and functional
- Your web app has sign up and sign in endpoints
- Both mobile app and web app are on the same network (for development)

## Step 1: Configure API Endpoints

### 1.1 Update API Configuration
Open `lib/config/api_config.dart` and configure the base URL:

```dart
// For Android emulator (most common)
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For physical device on same network
// static const String baseUrl = 'http://192.168.1.100:3000/api';

// For production
// static const String baseUrl = 'https://yourdomain.com/api';
```

### 1.2 Verify Endpoints
Make sure these endpoints match your web app:
- Sign Up: `/auth/signup`
- Sign In: `/auth/signin`
- User Profile: `/user/profile`

## Step 2: Network Configuration

### 2.1 For Android Emulator
- Use `http://10.0.2.2:3000/api` (this maps to localhost on your computer)
- Make sure your web app is running on port 3000

### 2.2 For Physical Device
1. Find your computer's IP address:
   - **Windows**: Run `ipconfig` in Command Prompt
   - **Mac/Linux**: Run `ifconfig` in Terminal
2. Use `http://[YOUR_IP]:3000/api`
3. Ensure both devices are on the same WiFi network

### 2.3 For Production
- Use your actual domain with HTTPS
- Example: `https://yourdomain.com/api`

## Step 3: Test Connection

### 3.1 Using the Test Button
1. Run your mobile app
2. Go to the Sign In screen
3. Tap "Test Connection" button
4. Check if connection is successful

### 3.2 Manual Testing
1. Start your web app
2. Run your mobile app
3. Try to sign up with a new account
4. Try to sign in with existing credentials

## Step 4: Troubleshooting

### 4.1 Connection Issues
**Problem**: "Network connection failed"
**Solutions**:
- Check if web app is running
- Verify the URL in `api_config.dart`
- Ensure both devices are on same network
- Check firewall settings

### 4.2 API Endpoint Issues
**Problem**: "Failed to sign up/sign in"
**Solutions**:
- Verify endpoint URLs match your web app
- Check web app logs for errors
- Ensure request format matches web app expectations

### 4.3 CORS Issues (if applicable)
If your web app has CORS enabled, ensure it allows requests from your mobile app's origin.

## Step 5: Database Synchronization

### 5.1 Shared Database
- Both mobile app and web app use the same database
- Users created from either app will be available in both
- No additional synchronization needed

### 5.2 Data Consistency
- User credentials work across both platforms
- Profile data is shared
- Authentication tokens are platform-specific but user data is unified

## Step 6: Security Considerations

### 6.1 Development
- Use HTTP for local development
- Ensure network is secure (same WiFi)

### 6.2 Production
- Always use HTTPS
- Implement proper token management
- Consider API rate limiting

## Step 7: Testing Checklist

- [ ] Web app is running and accessible
- [ ] API configuration is correct
- [ ] Connection test passes
- [ ] Sign up works from mobile app
- [ ] Sign in works with web app credentials
- [ ] Sign in works with mobile app credentials
- [ ] User data is shared between platforms

## Common Issues and Solutions

### Issue: "SocketException: Connection refused"
**Cause**: Web app not running or wrong URL
**Solution**: Start web app and verify URL

### Issue: "TimeoutException"
**Cause**: Network too slow or web app overloaded
**Solution**: Increase timeout in `api_config.dart` or check web app performance

### Issue: "FormatException: Invalid JSON"
**Cause**: Web app returning non-JSON response
**Solution**: Check web app endpoint implementation

## Support

If you encounter issues:
1. Check the console logs for detailed error messages
2. Verify your web app endpoints are working
3. Test with a simple HTTP client (Postman, curl)
4. Ensure network connectivity

## Next Steps

Once basic authentication is working:
1. Implement user profile management
2. Add password reset functionality
3. Implement session management
4. Add offline capabilities if needed
5. Implement push notifications 