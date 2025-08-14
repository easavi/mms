import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'config/environment.dart';
import 'providers/auth_provider.dart';
import 'providers/media_provider.dart';
import 'providers/file_upload_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/config/storage_screen.dart';
import 'screens/upload_status_screen.dart';
import 'widgets/authenticated_wrapper.dart';
import 'theme/app_theme.dart';

void main() {
  setupEnvironment(env: Environment.dev);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => FileUploadProvider()),
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
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return const AuthenticatedWrapper(
                child: MainScreen(),
              );
            } else {
              return const LoginScreen();
            }
          },
        ),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const AuthenticatedWrapper(
          child: MainScreen(),
        ),
        '/storages': (context) => const StorageScreen(),
        '/upload-status': (context) => const UploadStatusScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
