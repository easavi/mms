import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  final ApiService _apiService = ApiService();
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      // Remove the base URL from the image URL if it's already there
      String path = widget.imageUrl;
      if (path.startsWith('http://localhost:8080')) {
        path = path.substring('http://localhost:8080'.length);
      }

      debugPrint('🖼️ Loading authenticated image: ${widget.imageUrl}');
      debugPrint('🔗 Request path: $path');

      final response = await _apiService.dio.get(
        path,
        options: Options(responseType: ResponseType.bytes),
      );

      if (mounted) {
        setState(() {
          _imageBytes = Uint8List.fromList(response.data);
          _isLoading = false;
        });
        debugPrint('✅ Image loaded successfully');
      }
    } catch (e) {
      debugPrint('❌ Error loading authenticated image: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
        Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
    }

    if (_hasError || _imageBytes == null) {
      return widget.errorWidget ?? 
        Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
        );
    }

    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
    );
  }
}
