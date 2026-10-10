import 'package:dio/dio.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final Dio _dio;
  const AnnouncementRepositoryImpl(this._dio);

  @override
  Future<({List<Announcement> announcements, Failure? failure})> fetchAnnouncements() async {
    try {
      final res = await _dio.get('/announcements');
      final data = res.data as List<dynamic>;
      final items = data
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return (announcements: items, failure: null);
    } on DioException catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: ServerFailure(e.message ?? 'Gagal menghubungi server'),
      );
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: LocalFailure('Kesalahan sistem: $e'),
      );
    }
  }
}