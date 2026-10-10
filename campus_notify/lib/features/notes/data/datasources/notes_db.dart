import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openNotesDb() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'notes.db');

  return openDatabase(
    path,
    version: 2, // Naikkan versi database agar onCreate/onUpgrade berjalan
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    },
  );
}