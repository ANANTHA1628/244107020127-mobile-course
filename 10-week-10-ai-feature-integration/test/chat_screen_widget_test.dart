import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/features/chat_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      AiService.apiKeyStorageKey: 'mock-key',
    });
  });

  testWidgets('Menampilkan empty state dan saran prompt pada tampilan awal', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    expect(find.text('AI Campus Assistant'), findsOneWidget);
    expect(find.text('Halo, Mahasiswa Polinema!'), findsOneWidget);
    expect(find.text('Jadwal kuliah hari ini?'), findsOneWidget);
    expect(find.text('Cara mencatat di menu Notes?'), findsOneWidget);
  });

  testWidgets('Menampilkan peringatan privasi saat input terdeteksi NIK', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    final inputField = find.byType(TextField);
    await tester.enterText(inputField, 'Ini NIK saya 3507123456780001');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.textContaining('Peringatan Privasi: Terdeteksi NIK'), findsOneWidget);
  });

  testWidgets('Menampilkan dialog fallback ketika pemanggilan AI API gagal', (tester) async {
    final mockClient = MockClient((request) async {
      return http.Response('Service Unavailable', 503);
    });
    final failingService = AiService(client: mockClient);

    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(aiService: failingService),
      ),
    );

    final inputField = find.byType(TextField);
    await tester.enterText(inputField, 'Jadwal kuliah');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    // Dialog fallback tampil
    expect(find.text('Layanan AI Sibuk'), findsOneWidget);
    expect(find.text('Mode Offline'), findsOneWidget);

    // Klik tombol Mode Offline
    await tester.tap(find.text('Mode Offline'));
    await tester.pumpAndSettle();

    // Respons offline muncul di layar
    expect(find.textContaining('[Mode Offline]'), findsOneWidget);
  });
}
