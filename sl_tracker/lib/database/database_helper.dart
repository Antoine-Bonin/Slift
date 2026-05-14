import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Pattern Singleton : garantit qu'on n'ouvre qu'une seule connexion à la fois
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sl_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Ouvre (ou crée) la base de données
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Création des tables lors du premier lancement
  Future _createDB(Database db, int version) async {
    // Table des Templates
    // day_of_week : 1 (Lundi) à 7 (Dimanche)
    // rpe : peut être NULL (si c'est un template général pour le jour)
      await db.execute('''
        CREATE TABLE templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          day_of_week INTEGER NOT NULL,
          rpe INTEGER,
          content TEXT NOT NULL
        )
      ''');

    await db.execute('''
      CREATE TABLE block_config (
        id INTEGER PRIMARY KEY CHECK (id = 0), -- On ne garde qu'une seule config (ID 0)
        total_weeks INTEGER NOT NULL DEFAULT 4,
        current_week INTEGER NOT NULL DEFAULT 1,
        rpe_sequence TEXT NOT NULL DEFAULT '7,8,9,6' -- Les RPE séparés par des virgules
  )
''');

// Insertion d'une config par défaut au premier démarrage
    await db.insert('block_config', {
      'id': 0,
      'total_weeks': 4,
      'current_week': 1,
      'rpe_sequence': '7,8,9,6'
    });

    // Table des Séances (Le bloc-notes)
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL
      )
    ''');
  }

  // --- MÉTHODES POUR LES TEMPLATES ---

  // Ajouter ou mettre à jour un template
  Future<int> insertTemplate(Map<String, dynamic> template) async {
    final db = await instance.database;
    // ConflictAlgorithm.replace permet d'écraser l'ancien si on a le même ID
    return await db.insert('templates', template, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Récupérer tous les templates (pour afficher dans les paramètres)
  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await instance.database;
    return await db.query('templates', orderBy: 'day_of_week ASC');
  }

  // L'algorithme "Intelligent" de récupération
  Future<Map<String, dynamic>?> getTemplateForDayAndRpe(int day, int? rpe) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps = [];
    
    // 1. On cherche d'abord s'il y a un template ultra-précis (ex: Lundi ET RPE 7)
    if (rpe != null) {
      maps = await db.query('templates', where: 'day_of_week = ? AND rpe = ?', whereArgs: [day, rpe]);
    }
    
    // 2. Si on n'a rien trouvé (ou pas de RPE fourni), on cherche le template par défaut du jour
    if (maps.isEmpty) {
      maps = await db.query('templates', where: 'day_of_week = ? AND rpe IS NULL', whereArgs: [day]);
    }
    
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // --- MÉTHODES POUR LES SÉANCES ---

  // Sauvegarder la séance du jour
  Future<int> saveSession(String date, String content) async {
    final db = await instance.database;
    return await db.insert('sessions', 
      {'date': date, 'content': content}, 
      conflictAlgorithm: ConflictAlgorithm.replace // Écrase si on modifie la note plus tard
    );
  }

  // Récupérer la note d'une séance précise
  Future<Map<String, dynamic>?> getSession(String date) async {
    final db = await instance.database;
    final maps = await db.query('sessions', where: 'date = ?', whereArgs: [date]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // Récupérer la config du bloc (ID 0)
Future<Map<String, dynamic>> getBlockConfig() async {
  final db = await instance.database;
  final result = await db.query('block_config', where: 'id = 0');
  return result.first;
}

// Mettre à jour la config
Future<int> updateBlockConfig(Map<String, dynamic> config) async {
  final db = await instance.database;
  return await db.update('block_config', config, where: 'id = 0');
}

}