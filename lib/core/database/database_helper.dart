import 'package:sqflite/sqflite.dart'; // Package pour manipuler SQLite en Dart
import 'package:path/path.dart'; // Pour construire des chemins de fichiers compatibles
import 'database_migrations.dart'; // Pour gérer les migrations de la base

// Classe utilitaire pour gérer la base de données SQLite
class DatabaseHelper {
  // Singleton : une seule instance partagée dans toute l'app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Constructeur privé pour le singleton
  DatabaseHelper._init();

  // Getter asynchrone pour obtenir la base de données (l'ouvre si besoin)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hackernews.db');
    return _database!;
  }

  // Initialise la base de données à partir d'un nom de fichier
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Chemin du dossier des bases
    final path = join(dbPath, filePath); // Chemin complet du fichier DB

    // Ouvre la base, crée ou migre si besoin
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // Appelé si la base n'existe pas
      onUpgrade:
          DatabaseMigrations.onUpgrade, // Pour les migrations ascendantes
      onDowngrade:
          DatabaseMigrations.onDowngrade, // Pour les migrations descendantes
    );
  }

  // Crée les tables et index lors de la première création de la base
  Future<void> _createDB(Database db, int version) async {
    // Types SQL utilisés pour la création des tables
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    // Table des articles
    await db.execute('''
      CREATE TABLE articles (
        id $idType,
        title $textType,
        url $textType,
        text $textType,
        author $textType,
        score $integerType,
        time $integerType,
        kids $textType,
        descendants $integerType,
        type $textType,
        is_deleted $boolType,
        is_dead $boolType,
        is_favorite $boolType,
        cached_at $textType
      )
    ''');

    // Table des commentaires
    await db.execute('''
      CREATE TABLE comments (
        id $idType,
        text $textType,
        author $textType,
        time $integerType,
        kids $textType,
        parent $integerType,
        is_deleted $boolType,
        is_dead $boolType,
        level $integerType,
        article_id $integerType,
        cached_at $textType,
        FOREIGN KEY (article_id) REFERENCES articles (id) ON DELETE CASCADE
      )
    ''');

    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id $textType PRIMARY KEY,
        created $integerType,
        karma $integerType,
        about $textType,
        submitted $textType,
        cached_at $textType
      )
    ''');

    // Index pour accélérer les requêtes sur certains champs
    await db.execute('CREATE INDEX idx_articles_time ON articles(time DESC)');
    await db.execute(
      'CREATE INDEX idx_articles_favorite ON articles(is_favorite)',
    );
    await db.execute('CREATE INDEX idx_comments_parent ON comments(parent)');
    await db.execute(
      'CREATE INDEX idx_comments_article ON comments(article_id)',
    );
  }

  // Ferme la base de données proprement
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
