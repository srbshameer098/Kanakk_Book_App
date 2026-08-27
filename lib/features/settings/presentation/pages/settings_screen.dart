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
    if (!_isPremium) {
      PremiumService.showUpgradePrompt(context, feature: 'Backup & Restore');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Choose an action below. Creating a backup will save a JSON file to your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              BackupRestoreService.restoreBackup(context);
            },
            child: const Text('RESTORE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              BackupRestoreService.manualBackup(context);
            },
            child: const Text('BACKUP'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
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
                    'Kada Kanakku Premium',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: OutlinedButton(
                      onPressed: () async {
                        // Testing: Allow user to revert to free version
                        await PremiumService.setPremium(false);
                        _loadSettings();
                      },
                      child: const Text('Revert to Free Version (Test Mode)'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
