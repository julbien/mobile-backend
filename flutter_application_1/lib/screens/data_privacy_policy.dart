import 'package:flutter/material.dart';

// screen for displaying the Data Privacy Policy
class DataPrivacyPolicyScreen extends StatelessWidget {
  const DataPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title of the page
        title: const Text('Data Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // main content of the privacy policy
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // title
              Text(
                'Data Privacy Policy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Effective Date: July 2025',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'MyPathPal App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // intro
              Text(
                'At MyPathPal, we value your privacy and are committed to protecting your personal information. This policy outlines how we collect, use, and secure the data you provide when using our mobile application.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Section 1: Information We Collect
              Text('1. Information We Collect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('When you use the MyPathPal app, we may collect the following types of information:'),
              Text('• Email Address'),
              Text('• Contact Number'),
              Text('• Account Credentials (Username and Password)'),
              SizedBox(height: 16),
              // Section 2: Purpose of Data Collection
              Text('2. Purpose of Data Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('We collect your data to:'),
              Text('• Create and manage your user account'),
              Text('• Provide personalized guidance and app features'),
              Text('• Improve app functionality and user experience'),
              Text('• Communicate important updates, reminders, or support notifications'),
              Text('• Maintain system security and performance'),
              SizedBox(height: 16),
              // Section 3: Data Sharing and Disclosure
              Text('3. Data Sharing and Disclosure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('We do not sell or share your personal information with third parties for marketing purposes. Data may be accessed only by:'),
              Text('• Authorized MyPathPal personnel'),
              Text('• Trusted service providers who support app operations, under confidentiality agreements'),
              Text('• Government agencies only when legally required'),
              SizedBox(height: 16),
              // Section 4: Data Security
              Text('4. Data Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('Your information is stored securely using industry-standard practices, including:'),
              Text('• Encrypted storage'),
              Text('• Secure servers and systems'),
              Text('• Access restrictions to authorized personnel only'),
              Text('• Regular security checks and system updates'),
              SizedBox(height: 16),
              // Section 5: Consent
              Text('5. Consent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('By signing up and using MyPathPal, you agree to the collection and use of your data as outlined in this policy.'),
              SizedBox(height: 16),
              // Section 6: Contact Us
              Text('6. Contact Us', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text('For any privacy-related inquiries, you may reach us at:'),
              Text('📧 mypathpal@example.com'),
              Text('📞 09123456789'),
            ],
          ),
        ),
      ),
    );
  }
} 