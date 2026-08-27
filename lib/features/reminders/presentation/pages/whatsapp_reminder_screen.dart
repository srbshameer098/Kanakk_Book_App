import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/services/shop_settings_service.dart';
import '../../../customers/data/models/customer.dart';

class WhatsappReminderScreen extends StatefulWidget {
  final Customer customer;

  const WhatsappReminderScreen({super.key, required this.customer});

  @override
  State<WhatsappReminderScreen> createState() => _WhatsappReminderScreenState();
}

class _WhatsappReminderScreenState extends State<WhatsappReminderScreen> {
  String _selectedLanguage = 'English';
  String _selectedTemplate = 'Friendly';
  bool _isLoading = false;
  String _shopName = 'Kada Kanakku Shop';

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final name = await ShopSettingsService.getShopName();
    setState(() {
      _shopName = name;
    });
  }

  void _sendReminder() async {
    if (widget.customer.mobileNumber == null || widget.customer.mobileNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer does not have a valid mobile number')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await WhatsAppService.sendReminderMessage(
      phoneNumber: widget.customer.mobileNumber!,
      customerName: widget.customer.name,
      amount: widget.customer.currentBalance,
      shopName: _shopName,
      language: _selectedLanguage,
      template: _selectedTemplate,
    );

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.customer.name, style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text('Pending: ₹${widget.customer.currentBalance}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.credit, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose Language', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'English', label: Text('English')),
                ButtonSegment(value: 'Malayalam', label: Text('Malayalam')),
              ],
              selected: {_selectedLanguage},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedLanguage = set.first;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text('Choose Message Template', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTemplate,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Friendly', child: Text('Friendly')),
                DropdownMenuItem(value: 'Professional', child: Text('Professional')),
                DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedTemplate = val);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send),
              label: Text(_isLoading ? 'OPENING...' : 'SEND VIA WHATSAPP'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              onPressed: _isLoading ? null : _sendReminder,
            ),
          ],
        ),
      ),
    );
  }
}
