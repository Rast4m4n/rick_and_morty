import 'package:path/path.dart';
import 'package:rick_and_morty/core/storage/i_data_storage.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';
import 'package:sqflite/sqflite.dart';

class SqlDatabase implements IDataStorage {
  SqlDatabase._internal();
  factory SqlDatabase() {
    return db;
  }
  static final SqlDatabase db = SqlDatabase._internal();

  static const _databaseName = 'rick_and_morty.db';
  static const _databaseVersion = 1;

  Future<Database> get database async => await init();

  @override
  Future<Database> init() async {
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE info (
        count INTEGER PRIMARY KEY,
        pages INTEGER,
        next TEXT,
        prev TEXT
      )
    ''');
        // связь count персонажа с count инфы нужна для отображения персонажей
        // из конкретных страниц и последующей фильтрации SELECT
        await db.execute('''
      CREATE TABLE characters(
        id INTEGER PRIMARY KEY, 
        count INTEGER,
        name TEXT,
        status TEXT,
        species TEXT,
        type TEXT,
        gender TEXT,
        image TEXT,
        url TEXT,
        created INTEGER,
        isFavorite INTEGER DEFAULT 0,
        FOREIGN KEY (count) REFERENCES info (count)

      )
''');
      },
    );
  }

  @override
  Future<void> cacheCharacters(ApiResponse response, int page) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert('info', {
        'count': page,
        'pages': response.info.pages,
        'next': response.info.next,
        'prev': response.info.prev,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Сохраняем персонажей страницы
      for (final character in response.results) {
        await txn.insert('characters', {
          'id': character.id,
          'count': page,
          'name': character.name,
          'status': character.status,
          'species': character.species,
          'type': character.type,
          'gender': character.gender,
          'image': character.image,
          'url': character.url,
          'created': character.created.millisecondsSinceEpoch,
          'isFavorite': character.isFavorite ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<ApiResponse?> loadCacheCharacters(int page) async {
    final db = await database;

    final pageInfo = await db.query(
      'info',
      where: 'count = ?',
      whereArgs: [page],
    );

    if (pageInfo.isEmpty) return null;

    final characters = await db.query(
      'characters',
      where: 'count = ?',
      whereArgs: [page],
    );

    if (characters.isEmpty) return null;

    // Получаю количество закешированных страниц
    final cachedPagesInfo = await db.query('info');
    final cachedPagesCount = cachedPagesInfo.length;

    return ApiResponse(
      info: InfoModel(
        count: characters.length,
        pages: cachedPagesCount,
        next: pageInfo.first['next'] as String?,
        prev: pageInfo.first['prev'] as String?,
      ),
      results: characters.map((e) => CharacterModel.fromMap(e)).toList(),
    );
  }

  @override
  Future<List<CharacterModel>> loadFavoriteCharacter() {
    throw UnimplementedError();
  }

  @override
  Future<void> makeFavoriteOrRemoveCharacter(CharacterModel character) async {
    if (character.isFavorite) {
      await _saveFavoriteCharacter(character);
    } else {
      await _removeFavoriteCharacter(character);
    }
  }

  Future<void> _saveFavoriteCharacter(CharacterModel character) async {
    throw UnimplementedError();
  }

  Future<void> _removeFavoriteCharacter(CharacterModel character) async {
    throw UnimplementedError();
  }
}
