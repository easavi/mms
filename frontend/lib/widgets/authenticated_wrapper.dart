import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/file_upload_provider.dart';

/// Wrapper widget that initializes file upload service when user is authenticated
class AuthenticatedWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthenticatedWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthenticatedWrapper> createState() => _AuthenticatedWrapperState();
}

class _AuthenticatedWrapperState extends State<AuthenticatedWrapper> {
  bool _fileUploadInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFileUploadService();
    });
  }

  Future<void> _initializeFileUploadService() async {
    final authProvider = context.read<AuthProvider>();
    final fileUploadProvider = context.read<FileUploadProvider>();

    if (authProvider.isAuthenticated && !_fileUploadInitialized) {
      try {
        debugPrint('🚀 Initializing File Upload Service for authenticated user...');
        await fileUploadProvider.initialize();
        _fileUploadInitialized = true;
        debugPrint('✅ File Upload Service initialized successfully');
      } catch (e) {
        debugPrint('❌ Failed to initialize File Upload Service: $e');
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start file monitoring: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, FileUploadProvider>(
      builder: (context, authProvider, fileUploadProvider, child) {
        // Initialize file upload service when user logs in
        if (authProvider.isAuthenticated && !_fileUploadInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFileUploadService();
          });
        }
        
        // Stop file upload service when user logs out
        if (!authProvider.isAuthenticated && _fileUploadInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debugPrint('🛑 Stopping File Upload Service for logged out user...');
            await fileUploadProvider.stop();
            _fileUploadInitialized = false;
            debugPrint('✅ File Upload Service stopped');
          });
        }
        
        return widget.child;
      },
    );
  }
}
