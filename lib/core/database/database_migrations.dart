// core/database/database_migrations.dart
import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 2:
          await _upgradeToV2(db);
          break;
        case 3:
          await _upgradeToV3(db);
          break;
        // Add more versions as needed
      }
    }
  }

  static Future<void> _upgradeToV2(Database db) async {
    // Example migration: Add index for better performance
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_articles_cached_at ON articles(cached_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_comments_level ON comments(level)',
    );
  }

  static Future<void> _upgradeToV3(Database db) async {
    // Example migration: Add new column
    await db.execute(
      'ALTER TABLE articles ADD COLUMN read_status INTEGER DEFAULT 0',
    );
  }

  static Future<void> onDowngrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle downgrade if necessary
    // Usually, we drop and recreate tables
    await db.execute('DROP TABLE IF EXISTS articles');
    await db.execute('DROP TABLE IF EXISTS comments');
    await db.execute('DROP TABLE IF EXISTS users');

    // Recreate with new schema
    // This would call the original create methods
  }
}
