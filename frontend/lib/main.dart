import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/main/main_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/config/environment.dart';

void main() {
  
  setupEnvironment(env: Environment.dev);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimedia Sharing',
      theme: AppTheme.darkTheme,
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Check auth status on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authService.checkAuthStatus();
          });
          
          if (authService.isAuthenticated) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
