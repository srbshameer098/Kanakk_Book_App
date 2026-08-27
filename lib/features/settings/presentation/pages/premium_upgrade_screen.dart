import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/iap_service.dart';
import '../../../../core/services/premium_service.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final IAPService _iapService = IAPService();

  @override
  void initState() {
    super.initState();
    _iapService.addListener(_onIapStateChanged);
  }

  @override
  void dispose() {
    _iapService.removeListener(_onIapStateChanged);
    super.dispose();
  }

  void _onIapStateChanged() {
    setState(() {}); // Rebuild UI when IAP state changes
    _checkIfPurchased();
  }

  Future<void> _checkIfPurchased() async {
    // If during the stream update, the premium flag was set to true
    if (await PremiumService.isPremium()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Kada Kanakku Premium! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _handlePurchase(String productId) {
    debugPrint('Requested product: $productId');
    debugPrint('Store available: ${_iapService.isAvailable}');

    debugPrint('Available products:');
    for (final product in _iapService.products) {
      debugPrint(
        'ID: ${product.id} | '
        'Title: ${product.title} | '
        'Price: ${product.price}',
      );
    }

    if (!_iapService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Play Billing is currently unavailable. Please try again later.',
          ),
        ),
      );
      return;
    }

    final product = _iapService.products.where(
      (product) => product.id == productId,
    );

    if (product.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "$productId" was not found in Google Play.'),
        ),
      );
      return;
    }

    _iapService.buyProduct(product.first);
  }

  Future<void> _simulatePurchaseFallback(String productId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store unavailable. Simulating purchase (Test Mode)...'),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    await PremiumService.setPremium(true);
    _checkIfPurchased();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              if (_iapService.isAvailable) {
                _iapService.restorePurchases();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Store unavailable. Cannot restore.'),
                  ),
                );
              }
            },
            child: const Text('Restore', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.workspace_premium,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kada Kanakku\nPremium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unlock the full potential of your business.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Features List
                _buildFeatureRow(Icons.block, 'No advertisements'),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  Icons.people,
                  'Unlimited customers & transactions',
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  Icons.picture_as_pdf,
                  'PDF reports & advanced reports',
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  Icons.sync,
                  'Backup and restore (Coming soon)',
                ),

                const SizedBox(height: 32),

                if (_iapService.isPurchasing)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildPlanCard(
                    title: 'Monthly Premium',
                    price: '₹49/month',
                    productId: 'premium_monthly',
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: 'Yearly Premium',
                    price: '₹399/year',
                    productId: 'premium_yearly',
                    color: AppColors.primary,
                    isPopular: true,
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: 'Lifetime Premium',
                    price: '₹999 one-time',
                    productId: 'premium-lifetime',
                    color: Colors.amber[800]!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String productId,
    required Color color,
    bool isPopular = false,
  }) {
    // Try to get real price from store if available
    String displayPrice = price;
    if (_iapService.isAvailable && _iapService.products.isNotEmpty) {
      try {
        final prod = _iapService.products.firstWhere((p) => p.id == productId);
        displayPrice = prod.price;
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => _handlePurchase(productId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? color : Colors.grey.withOpacity(0.3),
            width: isPopular ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayPrice,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber[800], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
