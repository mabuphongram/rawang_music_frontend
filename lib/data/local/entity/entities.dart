enum OwnerType {
  singer,
  organization,
  anonymous
}

enum UserRole {
  user,
  artist,
  admin
}

enum SubscriptionPlan {
  free,
  oneMonth,
  threeMonths,
  oneYear
}

enum SubscriptionStatus {
  active,
  expired,
  pending
}

class SocialLinks {
  final String youtube;
  final String facebook;
  final String tiktok;

  const SocialLinks({
    this.youtube = '',
    this.facebook = '',
    this.tiktok = '',
  });

  factory SocialLinks.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SocialLinks();
    return SocialLinks(
      youtube: (map['youtube'] ?? '').toString(),
      facebook: (map['facebook'] ?? '').toString(),
      tiktok: (map['tiktok'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'youtube': youtube,
        'facebook': facebook,
        'tiktok': tiktok,
      };

  bool get hasAny => youtube.isNotEmpty || facebook.isNotEmpty || tiktok.isNotEmpty;
}

class OwnerEntity {
  final String id;
  final String name;
  final String avatarUrl; // relative path stored in MongoDB, resolved at runtime
  final String description;
  final String ownerType; // 'singer' or 'organization'
  final String phone;
  final SocialLinks socialLinks;
  final int albumCount;
  final int trackCount;

  OwnerEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.description,
    required this.ownerType,
    this.phone = '',
    this.socialLinks = const SocialLinks(),
    this.albumCount = 0,
    this.trackCount = 0,
  });

  factory OwnerEntity.fromMap(Map<String, dynamic> map, {required String ownerType}) {
    // Backend may return socialLinks as nested object or flat fields; handle both.
    SocialLinks links;
    if (map['socialLinks'] is Map) {
      links = SocialLinks.fromMap((map['socialLinks'] as Map).cast<String, dynamic>());
    } else {
      links = SocialLinks(
        youtube: (map['youtube'] ?? '').toString(),
        facebook: (map['facebook'] ?? '').toString(),
        tiktok: (map['tiktok'] ?? '').toString(),
      );
    }
    return OwnerEntity(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      ownerType: (map['ownerType'] ?? ownerType).toString(),
      phone: (map['phone'] ?? '').toString(),
      socialLinks: links,
      albumCount: map['albumCount'] is int
          ? map['albumCount'] as int
          : int.tryParse((map['albumCount'] ?? '0').toString()) ?? 0,
      trackCount: map['trackCount'] is int
          ? map['trackCount'] as int
          : int.tryParse((map['trackCount'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'description': description,
        'ownerType': ownerType,
        'phone': phone,
        'youtube': socialLinks.youtube,
        'facebook': socialLinks.facebook,
        'tiktok': socialLinks.tiktok,
        'albumCount': albumCount,
        'trackCount': trackCount,
      };
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
    bool asBool(dynamic v) =>
        v == 1 || v == true || v == '1' || v == 'true' || v == 'True';
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final rawKaraokeUrl = map['karaokeAudioUrl'];
    final karaokeUrl = rawKaraokeUrl == null || rawKaraokeUrl.toString() == 'null'
        ? null
        : rawKaraokeUrl.toString();

    return TrackEntity(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      albumId: (map['albumId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      rawangTitle: (map['rawangTitle'] ?? '').toString(),
      artistName: (map['artistName'] ?? '').toString(),
      albumName: (map['albumName'] ?? '').toString(),
      ownerType: (map['ownerType'] ?? '').toString(),
      durationSeconds: asInt(map['durationSeconds']),
      audioUrl: (map['audioUrl'] ?? '').toString(),
      lyrics: (map['lyrics'] ?? '').toString(),
      genre: (map['genre'] ?? '').toString(),
      isDownloaded: asBool(map['isDownloaded']),
      isFavorite: asBool(map['isFavorite']),
      playCount: asInt(map['playCount']),
      hasKaraoke: asBool(map['hasKaraoke']) || (karaokeUrl != null && karaokeUrl.trim().isNotEmpty),
      karaokeAudioUrl: karaokeUrl,
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

class HeroSlideEntity {
  final String id;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String imageUrl; // relative MinIO key, resolved at runtime
  final int durationSeconds;
  final int order;
  final bool isActive;

  HeroSlideEntity({
    required this.id,
    this.eyebrow = '',
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.durationSeconds = 6,
    this.order = 0,
    this.isActive = true,
  });

  factory HeroSlideEntity.fromMap(Map<String, dynamic> map) {
    int asInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    bool asBool(dynamic v) =>
        v == 1 || v == true || v == '1' || v == 'true' || v == 'True';

    return HeroSlideEntity(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      eyebrow: (map['eyebrow'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      durationSeconds: asInt(map['durationSeconds'], 6).clamp(3, 60),
      order: asInt(map['order'], 0),
      isActive: map.containsKey('isActive') ? asBool(map['isActive']) : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eyebrow': eyebrow,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'order': order,
      'isActive': isActive ? 1 : 0,
    };
  }
}

class ChatMessageEntity {  final String id;
  final String senderName;
  final String message;
  final int timestamp;
  final bool isUser;

  ChatMessageEntity({
    required this.id,
    required this.senderName,
    required this.message,
    int? timestamp,
    this.isUser = false,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map) {
    return ChatMessageEntity(
      id: map['id'],
      senderName: map['senderName'],
      message: map['message'],
      timestamp: map['timestamp'],
      isUser: map['isUser'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'isUser': isUser ? 1 : 0,
    };
  }
}

class UserEntity {
  final String id;
  final String phone;
  final String? email;
  final String name;
  final String avatarUrl;
  final UserRole role;
  final SubscriptionPlan subscriptionPlan;
  final SubscriptionStatus subscriptionStatus;
  final int subscriptionExpiresAt; // epoch ms
  final int subscriptionStartedAt; // epoch ms
  final int? lastPaymentAt;
  final double? lastPaymentAmount;
  final bool mustChangePassword;
  final bool isVerified;
  final int createdTimestamp;
  final int updatedTimestamp;

  UserEntity({
    required this.id,
    required this.phone,
    this.email,
    required this.name,
    this.avatarUrl = '',
    this.role = UserRole.user,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.subscriptionStatus = SubscriptionStatus.active,
    required this.subscriptionExpiresAt,
    required this.subscriptionStartedAt,
    this.lastPaymentAt,
    this.lastPaymentAmount,
    this.mustChangePassword = false,
    this.isVerified = false,
    int? createdTimestamp,
    int? updatedTimestamp,
  })  : createdTimestamp = createdTimestamp ?? DateTime.now().millisecondsSinceEpoch,
        updatedTimestamp = updatedTimestamp ?? DateTime.now().millisecondsSinceEpoch;

  bool get isSubscriptionActive =>
      subscriptionStatus == SubscriptionStatus.active &&
      DateTime.now().millisecondsSinceEpoch < subscriptionExpiresAt;

  bool get isFreeTier => subscriptionPlan == SubscriptionPlan.free;

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    UserRole parseRole(String? v) {
      switch (v) {
        case 'artist':
          return UserRole.artist;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.user;
      }
    }

    SubscriptionPlan parsePlan(String? v) {
      switch (v) {
        case 'one_month':
          return SubscriptionPlan.oneMonth;
        case 'three_months':
          return SubscriptionPlan.threeMonths;
        case 'one_year':
          return SubscriptionPlan.oneYear;
        default:
          return SubscriptionPlan.free;
      }
    }

    SubscriptionStatus parseStatus(String? v) {
      switch (v) {
        case 'expired':
          return SubscriptionStatus.expired;
        case 'pending':
          return SubscriptionStatus.pending;
        default:
          return SubscriptionStatus.active;
      }
    }

    int parseTimestamp(dynamic v) {
      if (v == null) return DateTime.now().millisecondsSinceEpoch;
      if (v is int) return v;
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return dt.millisecondsSinceEpoch;
        return int.tryParse(v) ?? DateTime.now().millisecondsSinceEpoch;
      }
      return DateTime.now().millisecondsSinceEpoch;
    }

    return UserEntity(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: map['email']?.toString(),
      name: (map['name'] ?? '').toString(),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      role: parseRole(map['role']?.toString()),
      subscriptionPlan: parsePlan(map['subscriptionPlan']?.toString()),
      subscriptionStatus: parseStatus(map['subscriptionStatus']?.toString()),
      subscriptionExpiresAt: parseTimestamp(map['subscriptionExpiresAt']),
      subscriptionStartedAt: parseTimestamp(map['subscriptionStartedAt'] ?? map['createdAt']),
      lastPaymentAt: map['lastPaymentAt'] != null ? parseTimestamp(map['lastPaymentAt']) : null,
      lastPaymentAmount: map['lastPaymentAmount'] != null
          ? double.tryParse(map['lastPaymentAmount'].toString())
          : null,
      mustChangePassword: map['mustChangePassword'] == 1 || map['mustChangePassword'] == true,
      isVerified: map['isVerified'] == 1 || map['isVerified'] == true,
      createdTimestamp: parseTimestamp(map['createdAt'] ?? map['createdTimestamp']),
      updatedTimestamp: parseTimestamp(map['updatedAt'] ?? map['updatedTimestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    String planToString(SubscriptionPlan p) {
      switch (p) {
        case SubscriptionPlan.oneMonth:
          return 'one_month';
        case SubscriptionPlan.threeMonths:
          return 'three_months';
        case SubscriptionPlan.oneYear:
          return 'one_year';
        default:
          return 'free';
      }
    }

    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'subscriptionPlan': planToString(subscriptionPlan),
      'subscriptionStatus': subscriptionStatus.name,
      'subscriptionExpiresAt': subscriptionExpiresAt,
      'subscriptionStartedAt': subscriptionStartedAt,
      'lastPaymentAt': lastPaymentAt,
      'lastPaymentAmount': lastPaymentAmount,
      'mustChangePassword': mustChangePassword ? 1 : 0,
      'isVerified': isVerified ? 1 : 0,
      'createdAt': createdTimestamp,
      'updatedAt': updatedTimestamp,
    };
  }

  UserEntity copyWith({
    String? phone,
    String? email,
    String? name,
    String? avatarUrl,
    UserRole? role,
    SubscriptionPlan? subscriptionPlan,
    SubscriptionStatus? subscriptionStatus,
    int? subscriptionExpiresAt,
    int? subscriptionStartedAt,
    bool? mustChangePassword,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      subscriptionStartedAt: subscriptionStartedAt ?? this.subscriptionStartedAt,
      lastPaymentAt: lastPaymentAt,
      lastPaymentAmount: lastPaymentAmount,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      isVerified: isVerified ?? this.isVerified,
      createdTimestamp: createdTimestamp,
      updatedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
