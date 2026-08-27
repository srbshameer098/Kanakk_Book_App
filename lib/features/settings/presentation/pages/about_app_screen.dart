import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.storefront, size: 80, color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Kanakk Book',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 32),
              ],
            ),
          ),
          Card(
            color: AppColors.surface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Privacy Policy',
                      '''Privacy Policy for Kanakk Book
Effective Date: 26/08/2026
Kanakk Book respects your privacy. This Privacy Policy explains how information and data are handled when you use the Kanakk Book application.

1. Information and Data Storage
Kanakk Book allows users to manage customer details, credit records, payments, transactions, and other related information.
Currently, the data entered into Kanakk Book is stored locally on your device. We do not currently store your customer, financial, or transaction data on our own cloud servers.
You are responsible for keeping your device secure and protecting access to the application.

2. Data Backup and Restore
Kanakk Book may provide options to back up or export your data. Backup files may be stored in a location selected by you.
You are responsible for keeping your backup files safe and secure. We recommend creating regular backups to help prevent data loss caused by device failure, loss, damage, or deletion of the application.

3. Future Cloud Features
Kanakk Book may introduce optional features in the future, such as cloud backup, data synchronization, or account-based data storage.
If such features are introduced, this Privacy Policy will be updated to explain how the data is collected, stored, protected, and used. Where required, users will be notified and asked to take appropriate action before using such features.

4. Third-Party Services
Kanakk Book may use third-party services in the future, such as advertising, analytics, crash reporting, or other services.
If third-party services collect or process user information, this Privacy Policy will be updated accordingly.

5. Children's Privacy
Kanakk Book is not specifically intended for children under the age required by applicable laws to provide consent for the processing of their personal information.
We do not knowingly collect personal information from children.

6. Data Security
We take reasonable steps to design the application with data protection in mind. However, no method of electronic storage is completely secure.
Because data is currently stored locally on your device, you should protect your device with appropriate security measures.

7. Your Responsibility
You are responsible for the information entered into Kanakk Book, including customer and transaction details.
Please ensure that you have the necessary permission to store and manage information about your customers.

8. Changes to This Privacy Policy
We may update this Privacy Policy when the application changes or new features are introduced.
Any updates will be reflected in the Privacy Policy available within the application and/or through the official Privacy Policy page.

9. Contact Us
If you have any questions about this Privacy Policy, please contact us at:
srbshameer098@gmail.com''',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.primary),
                  title: const Text('Terms & Conditions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Terms & Conditions',
                      '''Terms & Conditions for Kanakk Book
Effective Date: 26/08/2026
By downloading, installing, or using Kanakk Book, you agree to these Terms & Conditions.

1. Use of the Application
Kanakk Book provides tools to help users record and manage customer credits, payments, transactions, and related business information.
You agree to use the application only for lawful purposes.

2. Accuracy of Information
You are responsible for ensuring that the information entered into Kanakk Book is accurate.
Kanakk Book does not guarantee the accuracy of information entered by users.

3. Local Data Storage
Currently, application data is primarily stored locally on your device.
You are responsible for maintaining backups of important information. We recommend regularly backing up your data where backup or export options are available.

4. Data Loss
Although we aim to provide a reliable application, Kanakk Book cannot guarantee that data will never be lost.
We are not responsible for data loss caused by circumstances including:
- Device damage or failure
- Loss or theft of your device
- Application deletion
- Operating system issues
- Failure to maintain backups
- User actions or incorrect data entry

5. Financial Disclaimer
Kanakk Book is a record-keeping and management tool only.
The application does not provide financial, legal, banking, tax, accounting, or investment advice.
You are responsible for verifying your financial records and transactions.

6. Future Features
Kanakk Book may introduce new features, including cloud backup, synchronization, accounts, or other services.
The availability and use of future features may be subject to additional terms or updated policies.

7. Changes to the Application
We may modify, improve, add, or remove features from Kanakk Book at any time.

8. Changes to These Terms
We may update these Terms & Conditions from time to time.
Continued use of Kanakk Book after an update may indicate acceptance of the updated Terms, where permitted by applicable law.

9. Contact Us
For questions, feedback, or support, please contact us at:
srbshameer098@gmail.com''',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: AppColors.primary),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _launchURL('mailto:srbshameer098@gmail.com?subject=App%20Support');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
