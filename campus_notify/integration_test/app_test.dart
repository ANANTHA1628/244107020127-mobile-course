import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_notify/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pengguna dapat melihat daftar catatan', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verifikasi Dashboard
    expect(find.text('Dashboard Kampus'), findsOneWidget);

    // Navigasi ke Notes
    await tester.tap(find.text('Buka Catatan (Notes)'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Kampus'), findsOneWidget);
  });
}
