import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/services/shop_settings_service.dart';
import '../../../../core/services/backup_restore_service.dart';
import 'premium_upgrade_screen.dart';
import 'shop_profile_screen.dart';
import 'about_app_screen.dart';
import '../widgets/ad_banner_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPremium = false;
  String _shopName = 'My Shop';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final status = await PremiumService.isPremium();
    final name = await ShopSettingsService.getShopName();
    setState(() {
      _isPremium = status;
      _shopName = name;
    });
  }

  void _navigateToUpgrade() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen()),
    );

    if (result == true) {
      _loadSettings(); // Reload to hide ads
    }
  }

  void _navigateToShopProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopProfileScreen()),
    );

    if (result == true) {
      _loadSettings(); // Reload shop name
    }
  }

  void _navigateToAboutApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutAppScreen()),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text('''Privacy Policy for Kanakk Book
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
srbshameer098@gmail.com'''),
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

  void _showBackupRestore() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_sync, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backup & Restore',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Save or restore your shop records safely',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.save_alt_rounded, color: Colors.blue),
                ),
                title: const Text('Save Backup to Documents', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Choose Documents or any folder on your device to save .json file'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  BackupRestoreService.saveBackupToDevice(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.green),
                ),
                title: const Text('Share / Save to Google Drive', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Send via Google Drive, WhatsApp, or Email'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  BackupRestoreService.shareBackup(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restore_rounded, color: Colors.orange),
                ),
                title: const Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select a saved backup file (.json) to restore data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  BackupRestoreService.restoreBackup(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
          Card(
            color: AppColors.surface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store, color: AppColors.primary),
                  title: const Text('Shop Profile'),
                  subtitle: Text(_shopName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _navigateToShopProfile,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: Text('language'.tr()),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        context.setLocale(Locale(val));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync, color: AppColors.primary),
                  title: const Text('Backup & Restore'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showBackupRestore,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacyPolicy,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: const Text('About App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _navigateToAboutApp,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: _isPremium
                ? AppColors.credit.withOpacity(0.1)
                : AppColors.surface,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.workspace_premium,
                    color: _isPremium ? AppColors.credit : Colors.amber,
                    size: 32,
                  ),
                  title: const Text(
                    'Kanakk Book Premium',
                    style: AppTextStyles.h3,
                  ),
                  subtitle: Text(
                    _isPremium
                        ? 'You are a Premium member.'
                        : 'Remove ads and unlock all features.',
                  ),
                  trailing: _isPremium
                      ? const Icon(Icons.check_circle, color: AppColors.credit)
                      : const Icon(Icons.chevron_right),
                  onTap: _isPremium ? null : _navigateToUpgrade,
                ),
                if (!_isPremium)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _navigateToUpgrade,
                        child: const Text(
                          'UPGRADE NOW - ₹399/yr',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                SizedBox.shrink()
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 16.0,
                  //     vertical: 8.0,
                  //   ),
                  //   child: OutlinedButton(
                  //     onPressed: () async {
                  //       // Testing: Allow user to revert to free version
                  //       await PremiumService.setPremium(false);
                  //       _loadSettings();
                  //     },
                  //     child: const Text('Revert to Free Version (Test Mode)'),
                  //   ),
                  // ),
              ],
            ),
          ),
          const AdBannerWidget(
            // TODO: Replace with your actual Ad Unit IDs for the Settings Page
            androidAdUnitId: 'ca-app-pub-3269435850779402/3408164442', 
            iosAdUnitId: 'ca-app-pub-3269435850779402/3408164442',
          ),
        ],
      ),
    )]));
  }
}
