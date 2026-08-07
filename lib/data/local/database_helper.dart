import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class DatabaseHelper {
  static const _databaseName = "rawang_database.db";
  static const _databaseVersion = 4;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // For versions older than 3 (which required a schema change from coverResName to coverImage),
      // we do a full reset.
      await db.execute("DROP TABLE IF EXISTS albums");
      await db.execute("DROP TABLE IF EXISTS tracks");
      await db.execute("DROP TABLE IF EXISTS playlists");
      await db.execute("DROP TABLE IF EXISTS playlist_tracks");
      await db.execute("DROP TABLE IF EXISTS chat_messages");
      await db.execute("DROP TABLE IF EXISTS owners");
      await _onCreate(db, newVersion);
      return;
    }

    if (oldVersion == 3) {
      // Incremental migration for v3 -> v4: just add the owners table
      // This preserves all existing tracks, favorites, and downloaded status.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS owners (
          id TEXT PRIMARY KEY,
          name TEXT,
          avatarUrl TEXT,
          description TEXT,
          ownerType TEXT
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE albums (
        id TEXT PRIMARY KEY,
        title TEXT,
        ownerType TEXT,
        ownerName TEXT,
        coverImage TEXT,
        releaseYear INTEGER,
        description TEXT,
        trackCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        albumId TEXT,
        title TEXT,
        rawangTitle TEXT,
        artistName TEXT,
        albumName TEXT,
        ownerType TEXT,
        durationSeconds INTEGER,
        audioUrl TEXT,
        lyrics TEXT,
        genre TEXT,
        isDownloaded INTEGER,
        isFavorite INTEGER,
        playCount INTEGER,
        hasKaraoke INTEGER,
        karaokeAudioUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        createdTimestamp INTEGER,
        iconName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_tracks (
        playlistId TEXT,
        trackId TEXT,
        PRIMARY KEY (playlistId, trackId)
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        senderName TEXT,
        message TEXT,
        timestamp INTEGER,
        attachedTrackId TEXT,
        attachedTrackTitle TEXT,
        isUser INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE owners (
        id TEXT PRIMARY KEY,
        name TEXT,
        avatarUrl TEXT,
        description TEXT,
        ownerType TEXT
      )
    ''');

    // Initial empty state, will sync from API
    // batch.commit(noResult: true);
  }

  Future<void>? _syncFuture;

  Future<void> syncFromApi() {
    if (_syncFuture != null) return _syncFuture!;
    _syncFuture = _performSync().whenComplete(() => _syncFuture = null);
    return _syncFuture!;
  }

  Future<void> _performSync() async {
    final results = await Future.wait([
      ApiService.fetchAlbums(),
      ApiService.fetchTracks(),
      ApiService.fetchPlaylists(),
      ApiService.fetchChatMessages(),
      ApiService.fetchOwners(),
    ]);

    final apiAlbums = results[0] as List<AlbumEntity>;
    final apiTracks = results[1] as List<TrackEntity>;
    final apiPlaylists = results[2] as List<PlaylistEntity>;
    final apiMessages = results[3] as List<ChatMessageEntity>;
    final apiOwners = results[4] as List<OwnerEntity>;

    final db = await database;

    await db.transaction((txn) async {
      Batch batch = txn.batch();

      for (var album in apiAlbums) {
        batch.insert('albums', album.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var owner in apiOwners) {
        batch.insert('owners', {
          'id': owner.id,
          'name': owner.name,
          'avatarUrl': owner.avatarUrl,
          'description': owner.description,
          'ownerType': owner.ownerType,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var playlist in apiPlaylists) {
        batch.insert('playlists', playlist.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var msg in apiMessages) {
        batch.insert('chat_messages', msg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Merge tracks carefully to preserve user's downloaded/favorite/playCount state
      final existingMaps = await txn.query('tracks');
      final existingTracks = existingMaps.map((e) => TrackEntity.fromMap(e)).toList();
      final Map<String, TrackEntity> existingTrackMap = { for (var t in existingTracks) t.id: t };

      for (var track in apiTracks) {
        var newTrack = track;
        if (existingTrackMap.containsKey(track.id)) {
          final existing = existingTrackMap[track.id]!;
          newTrack = newTrack.copyWith(
            isDownloaded: existing.isDownloaded,
            isFavorite: existing.isFavorite,
            playCount: existing.playCount,
          );
        }
        batch.insert('tracks', newTrack.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  // DAO equivalents
  Future<List<AlbumEntity>> getAllAlbums() async {
    final db = await database;
    final maps = await db.query('albums');
    return maps.map((e) => AlbumEntity.fromMap(e)).toList();
  }

  Future<List<OwnerEntity>> getAllOwners() async {
    final db = await database;
    final maps = await db.query('owners');
    return maps.map((e) => OwnerEntity.fromMap(e, ownerType: e['ownerType'] as String)).toList();
  }

  Future<List<TrackEntity>> getAllTracks() async {
    final db = await database;
    final maps = await db.query('tracks');
    return maps.map((e) => TrackEntity.fromMap(e)).toList();
  }

  Future<List<TrackEntity>> getTracksByAlbum(String albumId) async {
    final db = await database;
    final maps = await db.query('tracks', where: 'albumId = ?', whereArgs: [albumId]);
    return maps.map((e) => TrackEntity.fromMap(e)).toList();
  }

  Future<List<TrackEntity>> getDownloadedTracks() async {
    final db = await database;
    final maps = await db.query('tracks', where: 'isDownloaded = 1');
    return maps.map((e) => TrackEntity.fromMap(e)).toList();
  }

  Future<List<TrackEntity>> getFavoriteTracks() async {
    final db = await database;
    final maps = await db.query('tracks', where: 'isFavorite = 1');
    return maps.map((e) => TrackEntity.fromMap(e)).toList();
  }

  Future<void> updateDownloadStatus(String trackId, bool isDownloaded) async {
    final db = await database;
    await db.update('tracks', {'isDownloaded': isDownloaded ? 1 : 0}, where: 'id = ?', whereArgs: [trackId]);
  }

  Future<void> updateFavoriteStatus(String trackId, bool isFavorite) async {
    final db = await database;
    await db.update('tracks', {'isFavorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [trackId]);
  }

  Future<List<PlaylistEntity>> getAllPlaylists() async {
    final db = await database;
    final maps = await db.query('playlists');
    return maps.map((e) => PlaylistEntity.fromMap(e)).toList();
  }

  Future<List<TrackEntity>> getTracksForPlaylist(String playlistId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT t.* FROM tracks t
      INNER JOIN playlist_tracks pt ON t.id = pt.trackId
      WHERE pt.playlistId = ?
    ''', [playlistId]);
    return maps.map((e) => TrackEntity.fromMap(e)).toList();
  }
  
  Future<void> insertPlaylist(PlaylistEntity playlist) async {
    final db = await database;
    await db.insert('playlists', playlist.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertPlaylistTrack(String playlistId, String trackId) async {
    final db = await database;
    await db.insert('playlist_tracks', {'playlistId': playlistId, 'trackId': trackId}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deletePlaylistTrack(String playlistId, String trackId) async {
    final db = await database;
    await db.delete('playlist_tracks', where: 'playlistId = ? AND trackId = ?', whereArgs: [playlistId, trackId]);
  }

  Future<List<ChatMessageEntity>> getAllMessages() async {
    final db = await database;
    final maps = await db.query('chat_messages', orderBy: 'timestamp ASC');
    return maps.map((e) => ChatMessageEntity.fromMap(e)).toList();
  }

  Future<void> insertMessage(ChatMessageEntity message) async {
    final db = await database;
    await db.insert('chat_messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> insertTrack(TrackEntity track) async {
    final db = await database;
    await db.insert('tracks', track.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertAlbum(AlbumEntity album) async {
    final db = await database;
    await db.insert('albums', album.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
