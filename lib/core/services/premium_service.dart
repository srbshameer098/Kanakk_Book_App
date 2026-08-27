import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/settings/presentation/pages/premium_upgrade_screen.dart';

class PremiumService {
  static const String _kIsPremium = 'is_premium';
  
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsPremium) ?? false;
  }

  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPremium, value);
  }

  static void showUpgradePrompt(BuildContext context, {required String feature}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upgrade to Premium'),
          content: Text('$feature is only available for Premium members. Upgrade now to unlock all features.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LATER'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen()),
                );
              },
              child: const Text('UPGRADE', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
