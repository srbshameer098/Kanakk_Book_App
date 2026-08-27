import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> sendReminderMessage({
    required String phoneNumber,
    required String customerName,
    required int amount,
    required String shopName,
    required String language, // 'English' or 'Malayalam'
    required String template, // 'Friendly', 'Professional', 'Urgent'
  }) async {
    String message = '';

    if (language == 'English') {
      if (template == 'Friendly') {
        message = 'Hello $customerName,\n\nJust a friendly reminder from $shopName. You have a pending balance of ₹$amount. Please make the payment at your earliest convenience.\n\nThank you!';
      } else if (template == 'Professional') {
        message = 'Dear $customerName,\n\nThis is a payment reminder from $shopName. Your current outstanding balance is ₹$amount. Kindly arrange for the payment.\n\nRegards,\n$shopName';
      } else if (template == 'Urgent') {
        message = 'URGENT: $customerName,\n\nYour payment of ₹$amount to $shopName is overdue. Please settle the amount immediately to avoid any inconvenience.\n\nThank you.';
      }
    } else { // Malayalam
      if (template == 'Friendly') {
        message = 'നമസ്കാരം $customerName,\n\n$shopName-ൽ നിങ്ങളുടെ നിലവിലെ കുടിശ്ശിക ₹$amount ആണ്. സൗകര്യപ്രകാരം പണം അടയ്ക്കണമെന്ന് അഭ്യർത്ഥിക്കുന്നു.\n\nനന്ദി!';
      } else if (template == 'Professional') {
        message = 'പ്രിയ $customerName,\n\nഇതൊരു ഓർമ്മപ്പെടുത്തലാണ്. $shopName-ൽ നിങ്ങൾ ₹$amount നൽകാനുണ്ട്. ദയവായി ഈ തുക അടയ്ക്കുക.\n\nനന്ദി,\n$shopName';
      } else if (template == 'Urgent') {
        message = 'അടിയന്തിരം: $customerName,\n\n$shopName-ൽ നിങ്ങളുടെ കുടിശ്ശികയായ ₹$amount ഉടൻ തന്നെ അടച്ചുതീർക്കേണ്ടതാണ്. ദയവായി സഹകരിക്കുക.\n\nനന്ദി.';
      }
    }

    // Clean phone number
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber'; // Assume India code if not present
    }

    final url = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      return false;
    }
  }
}
