class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String debug = '/debug';
  static const String announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final dynamic rawRoute = data['route'];
  if (rawRoute == null || rawRoute is! String || rawRoute.trim().isEmpty) {
    return AppRoutes.root;
  }
  final cleanRoute = rawRoute.trim();
  return cleanRoute.startsWith('/') ? cleanRoute : '/$cleanRoute';
}