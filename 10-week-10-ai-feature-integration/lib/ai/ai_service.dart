import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PrivacyException implements Exception {
  final String message;
  const PrivacyException(this.message);

  @override
  String toString() => message;
}

class AiService {
  AiService({
    FlutterSecureStorage? storage,
    http.Client? client,
    String? apiUrl,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client(),
        _apiUrl = apiUrl ??
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  final FlutterSecureStorage _storage;
  final http.Client _client;
  final String _apiUrl;

  static const String apiKeyStorageKey = 'ai_api_key';

  // System prompt pembatas persona AI kampus
  static const String systemInstruction =
      'Kamu adalah asisten kampus Polinema yang ramah, sopan, dan informatif. '
      'Jawab dalam Bahasa Indonesia dengan ringkas, maksimal 2-3 kalimat. '
      'Jangan pernah meminta atau membocorkan data pribadi mahasiswa.';

  // Cache lokal untuk menghemat biaya panggilan API berulang
  final Map<String, String> _cache = {};

  // Validasi privasi: menolak data pribadi (NIK 16 digit atau nomor telepon)
  void validatePrivacy(String input) {
    final nikRegex = RegExp(r'\b\d{16}\b');
    final phoneRegex = RegExp(r'\b(08|\+628)[0-9]{8,11}\b');

    if (nikRegex.hasMatch(input)) {
      throw const PrivacyException(
        'Peringatan Privasi: Terdeteksi NIK (16 digit). Demi keamanan, dilarang mengirim data sensitif ke AI.',
      );
    }
    if (phoneRegex.hasMatch(input)) {
      throw const PrivacyException(
        'Peringatan Privasi: Terdeteksi nomor telepon. Demi keamanan, dilarang mengirim data kontak pribadi ke AI.',
      );
    }
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: apiKeyStorageKey, value: key.trim());
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: apiKeyStorageKey);
  }

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  // Fallback offline kampus saat API gagal / internet mati
  String getOfflineFallbackResponse(String question) {
    final q = question.toLowerCase();
    if (q.contains('jadwal') || q.contains('kuliah') || q.contains('senin')) {
      return '[Mode Offline] Jadwal perkuliahan dapat dilihat pada portal Siakad Polinema. Perkuliahan dimulai pukul 07.30 WIB.';
    } else if (q.contains('catatan') ||
        q.contains('notes')) {
      return '[Mode Offline] Anda dapat menggunakan fitur Catatan di menu utama untuk menyimpan memo perkuliahan secara lokal.';
    } else if (q.contains('pengumuman') ||
        q.contains('fcm') ||
        q.contains('notifikasi')) {
      return '[Mode Offline] Pengumuman terbaru kampus dapat diakses langsung melalui menu Pengumuman di Dashboard.';
    } else {
      return '[Mode Offline] Maaf, layanan AI daring sedang tidak dapat diakses. Silakan coba kembali nanti atau gunakan menu informasi lokal kampus.';
    }
  }

  Future<String> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      throw Exception('Pertanyaan tidak boleh kosong.');
    }

    // 1. Cek keamanan privasi (Privacy Guard)
    validatePrivacy(trimmed);

    // 2. Cek Cache lokal (Hemat biaya & rate limit)
    final cacheKey = trimmed.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 3. Baca API Key dari Secure Storage
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'API key tidak tersedia. Silakan atur di menu Pengaturan.');
    }

    // 4. Request ke AI API dengan System Prompt + User Prompt
    final fullPrompt = '$systemInstruction\n\nPertanyaan Mahasiswa: $trimmed';

    final response = await _client.post(
      Uri.parse('$_apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': fullPrompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          final reply = parts[0]['text'] as String;
          _cache[cacheKey] = reply;
          return reply;
        }
      }
      throw Exception('Format respons AI tidak valid.');
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }

  // Streaming response emulasi kata per kata untuk UX responsif
  Stream<String> askStream(String question) async* {
    final fullAnswer = await ask(question);
    final words = fullAnswer.split(' ');
    String accumulator = '';

    for (int i = 0; i < words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      accumulator += (i == 0 ? '' : ' ') + words[i];
      yield accumulator;
    }
  }
}
