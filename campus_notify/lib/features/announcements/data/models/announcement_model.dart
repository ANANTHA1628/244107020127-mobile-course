import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
    );
  }

  Announcement toEntity() => Announcement(
    id: id,
    title: title,
    content: content,
    publishedAt: publishedAt,
  );
}