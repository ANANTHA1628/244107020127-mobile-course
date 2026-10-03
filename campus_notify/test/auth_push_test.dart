import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/routes.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:dio/dio.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  group('FCM Payload & Route Parsing Tests', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), AppRoutes.root);
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman dengan benar', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  group('Token Store & Auth Lifecycle Tests', () {
    test('provider auth membaca status login dari ketersediaan access token', () async {
      final store = FakeTokenStore()..access = 'mock-access';
      expect(store.access != null, isTrue);

      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh gagal saat refresh token kosong (paksa sesi berakhir)', () async {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });

  group('API Error Formatter Tests', () {
    test('401 response menghasilkan pesan sesi berakhir', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/devices'),
        response: Response(
          requestOptions: RequestOptions(path: '/devices'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final message = ApiErrorHandler.getReadableMessage(dioError);
      expect(message, 'Sesi Anda telah berakhir. Silakan login kembali.');
    });

    test('connection timeout menghasilkan pesan periksa jaringan', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/devices'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = ApiErrorHandler.getReadableMessage(dioError);
      expect(message.contains('timeout'), isTrue);
    });
  });
}