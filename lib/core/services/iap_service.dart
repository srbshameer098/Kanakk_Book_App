import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'premium_service.dart';

class IAPService extends ChangeNotifier {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool isAvailable = false;
  List<ProductDetails> products = [];
  bool isPurchasing = false;

  final String _monthlyId = 'premium_monthly';
  final String _yearlyId = 'premium_yearly';
  final String _lifetimeId = 'premium_lifetime';

  final Set<String> _kProductIds = {
    'premium_monthly',
    'premium_yearly',
    'premium_lifetime'
  };

  void initialize() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('Purchase stream error: $error');
    });
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      notifyListeners();
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // InAppPurchaseAndroidPlatformAddition androidAddition = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      // Optional Android specific init
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds);
    if (response.error == null && response.productDetails.isNotEmpty) {
      products = response.productDetails;
      // Sort by price if possible, or leave as is
    }
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails product) async {
    isPurchasing = true;
    notifyListeners();

    late PurchaseParam purchaseParam;
    if (defaultTargetPlatform == TargetPlatform.android) {
      purchaseParam = GooglePlayPurchaseParam(productDetails: product);
    } else {
      purchaseParam = PurchaseParam(productDetails: product);
    }

    if (product.id == _lifetimeId) {
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Monthly and Yearly are subscriptions, but in IAP package they are treated similarly to non-consumables 
      // or you can use buyNonConsumable. Google Play handles the subscription status.
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    isPurchasing = true;
    notifyListeners();
    await _iap.restorePurchases();
    // After restore, the stream will receive the past purchases
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isPurchasing = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
        isPurchasing = false;
      }
    }
    notifyListeners();
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // If it's one of our premium products, grant premium
    if (_kProductIds.contains(purchaseDetails.productID)) {
      await PremiumService.setPremium(true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
