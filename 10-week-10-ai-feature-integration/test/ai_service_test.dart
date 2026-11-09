import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_notify/ai/ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      AiService.apiKeyStorageKey: 'test-gemini-key-12345',
    });
  });

  group('AiService - Privacy Guard Tests', () {
    test('Throws PrivacyException when NIK (16 digit) is entered', () {
      final service = AiService();
      expect(
        () => service.validatePrivacy('Tolong cek NIK 3507123456780001 saya'),
        throwsA(isA<PrivacyException>()),
      );
    });

    test('Throws PrivacyException when Indonesian phone number is entered', () {
      final service = AiService();
      expect(
        () => service.validatePrivacy('Hubungi saya di 081234567890'),
        throwsA(isA<PrivacyException>()),
      );
    });

    test('Passes valid public inquiry without sensitive data', () {
      final service = AiService();
      expect(
        () => service.validatePrivacy('Kapan jadwal ujian akhir semester?'),
        returnsNormally,
      );
    });
  });

  group('AiService - Offline Fallback Tests', () {
    test('Returns Siakad info when prompt contains jadwal/kuliah', () {
      final service = AiService();
      final reply = service.getOfflineFallbackResponse('jadwal kuliah hari senin apa?');
      expect(reply, contains('[Mode Offline]'));
      expect(reply, contains('Siakad Polinema'));
    });

    test('Returns notes guide when prompt contains notes/catatan', () {
      final service = AiService();
      final reply = service.getOfflineFallbackResponse('bagaimana cara buat catatan?');
      expect(reply, contains('[Mode Offline]'));
      expect(reply, contains('fitur Catatan'));
    });

    test('Returns default offline message for general query', () {
      final service = AiService();
      final reply = service.getOfflineFallbackResponse('siapa dekan elektro?');
      expect(reply, contains('[Mode Offline]'));
    });
  });

  group('AiService - API & Cache Tests', () {
    test('Throws exception if query is empty', () async {
      final service = AiService();
      expect(() => service.ask('   '), throwsException);
    });

    test('Successfully parses Gemini API response', () async {
      final mockClient = MockClient((request) async {
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Perkuliahan dimulai tepat waktu pukul 07.30 WIB.'}
                ]
              }
            }
          ]
        };
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = AiService(client: mockClient);
      final reply = await service.ask('Jam berapa kuliah dimulai?');
      expect(reply, equals('Perkuliahan dimulai tepat waktu pukul 07.30 WIB.'));
    });

    test('Uses local cache on duplicate question without extra HTTP calls', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Ini respons AI ter-cache.'}
                ]
              }
            }
          ]
        };
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = AiService(client: mockClient);
      final reply1 = await service.ask('Pertanyaan Sama');
      final reply2 = await service.ask('Pertanyaan Sama');

      expect(reply1, equals('Ini respons AI ter-cache.'));
      expect(reply2, equals('Ini respons AI ter-cache.'));
      expect(callCount, equals(1)); // HTTP request called only once!
    });

    test('Throws exception on HTTP error code (e.g. 500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = AiService(client: mockClient);
      expect(() => service.ask('Error test?'), throwsException);
    });

    test('Streams response chunk by chunk', () async {
      final mockClient = MockClient((request) async {
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Halo Kampus Polinema'}
                ]
              }
            }
          ]
        };
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = AiService(client: mockClient);
      final stream = service.askStream('Sapa kampus');
      final chunks = await stream.toList();

      expect(chunks.length, equals(3));
      expect(chunks[0], equals('Halo'));
      expect(chunks[1], equals('Halo Kampus'));
      expect(chunks[2], equals('Halo Kampus Polinema'));
    });
  });
}
