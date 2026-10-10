import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../data/repositories/announcement_repository_impl.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(ref.watch(apiClientProvider));
});

final getAnnouncementsUseCaseProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final getAnnouncements = ref.watch(getAnnouncementsUseCaseProvider);
  final result = await getAnnouncements();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});