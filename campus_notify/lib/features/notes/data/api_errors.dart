import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getReadableMessage(dynamic error) {
    if (error is! DioException) {
      return error?.toString().replaceAll('Exception: ', '') ??
          'Terjadi kesalahan yang tidak diketahui.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server kampus batas waktu (timeout). Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (statusCode == 403) {
          return 'Anda tidak memiliki hak akses ke data ini.';
        } else if (statusCode == 404) {
          return 'Layanan atau data kampus tidak ditemukan.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server kampus sedang mengalami gangguan teknis.';
        }
        return 'Permintaan gagal dengan kode respons: $statusCode.';
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Periksa koneksi internet perangkat Anda.';
      case DioExceptionType.cancel:
        return 'Permintaan data dibatalkan.';
      case DioExceptionType.unknown:
      default:
        return 'Terjadi kendala jaringan atau kesalahan sistem.';
    }
  }
}