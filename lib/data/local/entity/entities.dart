enum OwnerType {
  singer,
  organization,
  anonymous
}

class OwnerEntity {
  final String id;
  final String name;
  final String avatarUrl; // relative path stored in MongoDB, resolved at runtime
  final String description;
  final String ownerType; // 'singer' or 'organization'

  OwnerEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.description,
    required this.ownerType,
  });

  factory OwnerEntity.fromMap(Map<String, dynamic> map, {required String ownerType}) {
    return OwnerEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      description: map['description'] ?? '',
      ownerType: ownerType,
    );
  }
}

class AlbumEntity {
  final String id;
  final String title;
  final String ownerType;
  final String ownerName;
  final String coverImage; // relative Minio path, e.g. albums/abc/cover.png
  final int releaseYear;
  final String description;
  final int trackCount;

  AlbumEntity({
    required this.id,
    required this.title,
    required this.ownerType,
    required this.ownerName,
    required this.coverImage,
    required this.releaseYear,
    required this.description,
    required this.trackCount,
  });

  factory AlbumEntity.fromMap(Map<String, dynamic> map) {
    return AlbumEntity(
      id: map['id'],
      title: map['title'],
      ownerType: map['ownerType'],
      ownerName: map['ownerName'],
      coverImage: map['coverImage'] ?? map['coverResName'] ?? '',
      releaseYear: map['releaseYear'],
      description: map['description'],
      trackCount: map['trackCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ownerType': ownerType,
      'ownerName': ownerName,
      'coverImage': coverImage,
      'releaseYear': releaseYear,
      'description': description,
      'trackCount': trackCount,
    };
  }
}

class TrackEntity {
  final String id;
  final String albumId;
  final String title;
  final String rawangTitle;
  final String artistName;
  final String albumName;
  final String ownerType;
  final int durationSeconds;
  final String audioUrl;
  final String lyrics;
  final String genre;
  final bool isDownloaded;
  final bool isFavorite;
  final int playCount;
  final bool hasKaraoke;
  final String? karaokeAudioUrl;

  TrackEntity({
    required this.id,
    required this.albumId,
    required this.title,
    required this.rawangTitle,
    required this.artistName,
    required this.albumName,
    required this.ownerType,
    required this.durationSeconds,
    required this.audioUrl,
    required this.lyrics,
    required this.genre,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.playCount = 0,
    this.hasKaraoke = false,
    this.karaokeAudioUrl,
  });

  TrackEntity copyWith({
    String? id,
    String? albumId,
    String? title,
    String? rawangTitle,
    String? artistName,
    String? albumName,
    String? ownerType,
    int? durationSeconds,
    String? audioUrl,
    String? lyrics,
    String? genre,
    bool? isDownloaded,
    bool? isFavorite,
    int? playCount,
    bool? hasKaraoke,
    String? karaokeAudioUrl,
  }) {
    return TrackEntity(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      title: title ?? this.title,
      rawangTitle: rawangTitle ?? this.rawangTitle,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      ownerType: ownerType ?? this.ownerType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      lyrics: lyrics ?? this.lyrics,
      genre: genre ?? this.genre,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      hasKaraoke: hasKaraoke ?? this.hasKaraoke,
      karaokeAudioUrl: karaokeAudioUrl ?? this.karaokeAudioUrl,
    );
  }

  factory TrackEntity.fromMap(Map<String, dynamic> map) {
    return TrackEntity(
      id: map['id'],
      albumId: map['albumId'],
      title: map['title'],
      rawangTitle: map['rawangTitle'],
      artistName: map['artistName'],
      albumName: map['albumName'],
      ownerType: map['ownerType'],
      durationSeconds: map['durationSeconds'],
      audioUrl: map['audioUrl'],
      lyrics: map['lyrics'],
      genre: map['genre'],
      isDownloaded: map['isDownloaded'] == 1,
      isFavorite: map['isFavorite'] == 1,
      playCount: map['playCount'],
      hasKaraoke: map['hasKaraoke'] == 1,
      karaokeAudioUrl: map['karaokeAudioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'albumId': albumId,
      'title': title,
      'rawangTitle': rawangTitle,
      'artistName': artistName,
      'albumName': albumName,
      'ownerType': ownerType,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'lyrics': lyrics,
      'genre': genre,
      'isDownloaded': isDownloaded ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'playCount': playCount,
      'hasKaraoke': hasKaraoke ? 1 : 0,
      'karaokeAudioUrl': karaokeAudioUrl,
    };
  }
}

class PlaylistEntity {
  final String id;
  final String name;
  final String description;
  final int createdTimestamp;
  final String iconName;

  PlaylistEntity({
    required this.id,
    required this.name,
    required this.description,
    int? createdTimestamp,
    this.iconName = "favorite",
  }) : createdTimestamp = createdTimestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory PlaylistEntity.fromMap(Map<String, dynamic> map) {
    return PlaylistEntity(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdTimestamp: map['createdTimestamp'],
      iconName: map['iconName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdTimestamp': createdTimestamp,
      'iconName': iconName,
    };
  }
}

class PlaylistTrackCrossRef {
  final String playlistId;
  final String trackId;

  PlaylistTrackCrossRef({
    required this.playlistId,
    required this.trackId,
  });

  factory PlaylistTrackCrossRef.fromMap(Map<String, dynamic> map) {
    return PlaylistTrackCrossRef(
      playlistId: map['playlistId'],
      trackId: map['trackId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'trackId': trackId,
    };
  }
}

class ChatMessageEntity {
  final String id;
  final String senderName;
  final String message;
  final int timestamp;
  final String? attachedTrackId;
  final String? attachedTrackTitle;
  final bool isUser;

  ChatMessageEntity({
    required this.id,
    required this.senderName,
    required this.message,
    int? timestamp,
    this.attachedTrackId,
    this.attachedTrackTitle,
    this.isUser = false,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map) {
    return ChatMessageEntity(
      id: map['id'],
      senderName: map['senderName'],
      message: map['message'],
      timestamp: map['timestamp'],
      attachedTrackId: map['attachedTrackId'],
      attachedTrackTitle: map['attachedTrackTitle'],
      isUser: map['isUser'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'attachedTrackId': attachedTrackId,
      'attachedTrackTitle': attachedTrackTitle,
      'isUser': isUser ? 1 : 0,
    };
  }
}
