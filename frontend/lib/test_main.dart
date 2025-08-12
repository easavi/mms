import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _status = 'Idle';
  
  @override
  void initState() {
    super.initState();
    _testBackend();
  }

  Future<void> _testBackend() async {
    setState(() {
      _status = 'Testing backend...';
    });

    try {
      final dio = Dio();
      
      // Test 1: Simple health check
      setState(() {
        _status = 'Testing health endpoint...';
      });
      
      final healthResponse = await dio.get('http://localhost:8080/api/validation/health');
      print('Health response: ${healthResponse.data}');
      
      // Test 2: Try media endpoint (should return 401 but let's see the error)
      setState(() {
        _status = 'Testing media endpoint...';
      });
      
      try {
        final mediaResponse = await dio.get('http://localhost:8080/api/media');
        print('Media response: ${mediaResponse.data}');
      } catch (e) {
        print('Expected media error: $e');
      }
      
      setState(() {
        _status = 'Tests completed successfully!';
      });
      
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testBackend,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}
