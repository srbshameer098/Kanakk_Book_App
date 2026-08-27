import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/database/local_database_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/iap_service.dart';
import 'core/services/premium_service.dart';
import 'core/services/backup_restore_service.dart';
import 'features/customers/domain/repositories/customer_repository.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/pages/customer_list_screen.dart';
import 'features/dashboard/presentation/pages/main_navigation_screen.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/reports/presentation/bloc/report_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await MobileAds.instance.initialize();
  
  // Initialize IAP listener
  IAPService().initialize();
  
  // Initialize local database
  final dbService = LocalDatabaseService();
  await dbService.init();

  if (await PremiumService.isPremium()) {
    BackupRestoreService.createDailyBackup();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ml')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const KadaKanakkuApp(),
    ),
  );
}

class KadaKanakkuApp extends StatelessWidget {
  const KadaKanakkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CustomerBloc(repository: CustomerRepository())),
        BlocProvider(create: (context) => TransactionBloc(repository: TransactionRepository(), customerRepository: CustomerRepository())),
        BlocProvider(create: (context) => ReportBloc(repository: TransactionRepository())),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
