import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Sudah diisi default agar bisa langsung klik tombol masuk
  final _emailCtrl = TextEditingController(text: 'mahasiswa@kampus.ac.id');
  final _passCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              authState.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(authStateProvider.notifier).login(
                                _emailCtrl.text.trim(),
                                _passCtrl.text.trim(),
                              );
                        },
                        child: const Text('Masuk'),
                      ),
                    ),
              if (authState.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  '${authState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}