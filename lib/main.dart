import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/campus_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CampusProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const CampusOSApp(),
    ),
  );
}

class CampusOSApp extends StatelessWidget {
  const CampusOSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'CampusOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: auth.isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
