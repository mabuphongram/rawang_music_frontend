import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class DatabaseHelper {
  static const _databaseName = "rawang_database.db";
  static const _databaseVersion = 7;

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

    if (oldVersion < 5) {
      // v4 -> v5: add phone / socialLinks / stats columns for Image 1 design
      // Use ALTER TABLE with safe IF NOT EXISTS via try-catch for downgrade robustness.
      final cols = await db.rawQuery("PRAGMA table_info(owners)");
      final existing = cols.map((c) => c['name'] as String).toSet();
      if (!existing.contains('phone')) {
        await db.execute('ALTER TABLE owners ADD COLUMN phone TEXT DEFAULT ""');
      }
      if (!existing.contains('youtube')) {
        await db.execute('ALTER TABLE owners ADD COLUMN youtube TEXT DEFAULT ""');
      }
      if (!existing.contains('facebook')) {
        await db.execute('ALTER TABLE owners ADD COLUMN facebook TEXT DEFAULT ""');
      }
      if (!existing.contains('tiktok')) {
        await db.execute('ALTER TABLE owners ADD COLUMN tiktok TEXT DEFAULT ""');
      }
      if (!existing.contains('albumCount')) {
        await db.execute('ALTER TABLE owners ADD COLUMN albumCount INTEGER DEFAULT 0');
      }
      if (!existing.contains('trackCount')) {
        await db.execute('ALTER TABLE owners ADD COLUMN trackCount INTEGER DEFAULT 0');
      }
    }

    if (oldVersion < 6) {
      // v5 -> v6: add users table for Phone+Password JWT auth + manual subscription
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          phone TEXT UNIQUE,
          email TEXT,
          name TEXT,
          avatarUrl TEXT DEFAULT "",
          role TEXT DEFAULT "user",
          subscriptionPlan TEXT DEFAULT "free",
          subscriptionStatus TEXT DEFAULT "active",
          subscriptionExpiresAt INTEGER,
          subscriptionStartedAt INTEGER,
          lastPaymentAt INTEGER,
          lastPaymentAmount REAL,
          mustChangePassword INTEGER DEFAULT 0,
          isVerified INTEGER DEFAULT 0,
          createdAt INTEGER,
          updatedAt INTEGER
        )
      ''');
    }

    if (oldVersion < 7) {
      // v6 -> v7: add hero_slides table for home 16:9 carousel
      await db.execute('''
        CREATE TABLE IF NOT EXISTS hero_slides (
          id TEXT PRIMARY KEY,
          eyebrow TEXT DEFAULT "",
          title TEXT,
          subtitle TEXT DEFAULT "",
          imageUrl TEXT DEFAULT "",
          durationSeconds INTEGER DEFAULT 6,
          slideOrder INTEGER DEFAULT 0,
          isActive INTEGER DEFAULT 1
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
        ownerType TEXT,
        phone TEXT DEFAULT "",
        youtube TEXT DEFAULT "",
        facebook TEXT DEFAULT "",
        tiktok TEXT DEFAULT "",
        albumCount INTEGER DEFAULT 0,
        trackCount INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone TEXT UNIQUE,
        email TEXT,
        name TEXT,
        avatarUrl TEXT DEFAULT "",
        role TEXT DEFAULT "user",
        subscriptionPlan TEXT DEFAULT "free",
        subscriptionStatus TEXT DEFAULT "active",
        subscriptionExpiresAt INTEGER,
        subscriptionStartedAt INTEGER,
        lastPaymentAt INTEGER,
        lastPaymentAmount REAL,
        mustChangePassword INTEGER DEFAULT 0,
        isVerified INTEGER DEFAULT 0,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE hero_slides (
        id TEXT PRIMARY KEY,
        eyebrow TEXT DEFAULT "",
        title TEXT,
        subtitle TEXT DEFAULT "",
        imageUrl TEXT DEFAULT "",
        durationSeconds INTEGER DEFAULT 6,
        slideOrder INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1
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
      ApiService.fetchPlaylistsRaw(),
      ApiService.fetchChatMessages(),
      ApiService.fetchOwners(),
      ApiService.fetchHeroSlides(),
    ]);

    final apiAlbums = results[0] as List<AlbumEntity>;
    final apiTracks = results[1] as List<TrackEntity>;
    final apiPlaylistsRaw = results[2] as List<Map<String, dynamic>>;
    final apiMessages = results[3] as List<ChatMessageEntity>;
    final apiOwners = results[4] as List<OwnerEntity>;
    final apiHeroSlides = results[5] as List<HeroSlideEntity>;

    final apiPlaylists = apiPlaylistsRaw.map((j) => PlaylistEntity.fromMap(j)).toList();

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
          'phone': owner.phone,
          'youtube': owner.socialLinks.youtube,
          'facebook': owner.socialLinks.facebook,
          'tiktok': owner.socialLinks.tiktok,
          'albumCount': owner.albumCount,
          'trackCount': owner.trackCount,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var playlist in apiPlaylists) {
        batch.insert('playlists', playlist.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var msg in apiMessages) {
        batch.insert('chat_messages', msg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var slide in apiHeroSlides) {
        final m = slide.toMap();
        batch.insert('hero_slides', {
          'id': m['id'],
          'eyebrow': m['eyebrow'],
          'title': m['title'],
          'subtitle': m['subtitle'],
          'imageUrl': m['imageUrl'],
          'durationSeconds': m['durationSeconds'],
          'slideOrder': m['order'],
          'isActive': m['isActive'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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

      // Sync playlist_tracks from backend trackIds
      await txn.delete('playlist_tracks');
      for (var rawPlaylist in apiPlaylistsRaw) {
        final playlistId = rawPlaylist['id'] as String?;
        final trackIds = rawPlaylist['trackIds'];
        if (playlistId != null && trackIds is List) {
          for (var trackId in trackIds) {
            final tid = trackId is String ? trackId : trackId.toString();
            batch.insert('playlist_tracks', {
              'playlistId': playlistId,
              'trackId': tid,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
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

  Future<List<HeroSlideEntity>> getAllHeroSlides() async {
    final db = await database;
    final maps = await db.query('hero_slides', orderBy: 'slideOrder ASC');
    return maps.map((e) {
      final m = Map<String, dynamic>.from(e);
      m['order'] = m['slideOrder'] ?? 0;
      m.remove('slideOrder');
      return HeroSlideEntity.fromMap(m);
    }).toList();
  }

  Future<List<OwnerEntity>> getAllOwners() async {    final db = await database;
    final maps = await db.query('owners');
    return maps.map((e) {
      // Merge flat social columns into nested map for fromMap
      final m = Map<String, dynamic>.from(e);
      // Ensure socialLinks object exists for fromMap fallback
      if (m['youtube'] != null || m['facebook'] != null || m['tiktok'] != null) {
        m['socialLinks'] = {
          'youtube': m['youtube'] ?? '',
          'facebook': m['facebook'] ?? '',
          'tiktok': m['tiktok'] ?? '',
        };
      }
      return OwnerEntity.fromMap(m, ownerType: e['ownerType'] as String);
    }).toList();
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

  // ── Users DAO (Phone+Password JWT + manual subscription) ───────────────
  Future<void> upsertUser(UserEntity user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserEntity?> getCurrentUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1, orderBy: 'updatedAt DESC');
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  Future<UserEntity?> getUserByPhone(String phone) async {
    final db = await database;
    final maps = await db.query('users', where: 'phone = ?', whereArgs: [phone]);
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  Future<void> clearUsers() async {
    final db = await database;
    await db.delete('users');
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
