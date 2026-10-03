import 'package:flutter/material.dart';
import '../messaging/push_service.dart';

class DebugTokenPage extends StatefulWidget {
  const DebugTokenPage({super.key});

  @override
  State<DebugTokenPage> createState() => _DebugTokenPageState();
}

class _DebugTokenPageState extends State<DebugTokenPage> {
  String? _currentToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startFcm();
  }

  Future<void> _startFcm() async {
    await requestNotificationPermission();
    await initLocalNotifications();
    await initFcmToken(
      onToken: (token) async {
        if (!mounted) return;
        setState(() {
          _currentToken = token;
          _isLoading = false;
        });

        // Contoh pengiriman ke backend (sesuai instruksi praktikum):
        // await dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
        debugPrint('Token Terdaftar: ${maskToken(token)}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM Token')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'FCM Device Token (Masked):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        maskToken(_currentToken),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              const Text(
                '*Sesuai aturan laporan: Hanya 12 karakter pertama yang ditampilkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}