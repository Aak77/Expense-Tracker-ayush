import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  const storage = FlutterSecureStorage();
  final apiClient = ApiClient(storage: storage);
  final authProvider = AuthProvider(apiClient: apiClient, storage: storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        // Add other providers here
      ],
      child: const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final appRouter = AppRouter(authProvider).router;

    return MaterialApp.router(
      title: 'FinTrack',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
