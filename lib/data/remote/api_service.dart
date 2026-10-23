import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/auth_service.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.90.31:5000/api';

  // ─────────────────────────────────────────────
  // URL resolver — prepends MINIO_PREFIX and URL-encodes the result.
  // Handles: empty string, already-full URLs, relative paths with spaces.
  // ─────────────────────────────────────────────
  static String resolveMediaUrl(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final prefix = dotenv.env['MINIO_PREFIX'] ?? '';
    final clean = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final full = '$prefix$clean';
    // Uri.encodeFull keeps slashes intact but encodes spaces → %20, etc.
    return Uri.encodeFull(full);
  }

  // ─────────────────────────────────────────────
  // Owners – singers + organizations
  // ─────────────────────────────────────────────
  static Future<List<OwnerEntity>> fetchOwners() async {
    final results = <OwnerEntity>[];
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/singers'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse('$baseUrl/organizations'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5)),
      ]);

      if (responses[0].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[0].body);
        for (final j in data) results.add(OwnerEntity.fromMap(j, ownerType: 'singer'));
      }
      if (responses[1].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[1].body);
        for (final j in data) results.add(OwnerEntity.fromMap(j, ownerType: 'organization'));
      }
    } catch (e) {
      print('Error fetching owners: $e');
    }
    return results;
  }

  // ─────────────────────────────────────────────
  // Albums
  // ─────────────────────────────────────────────
  static Future<List<AlbumEntity>> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/albums'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => AlbumEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching albums: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Tracks
  // ─────────────────────────────────────────────
  static Future<List<TrackEntity>> fetchTracks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tracks'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => TrackEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    }
    return [];
  }

  static Future<List<TrackEntity>> fetchPopularTracks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tracks/popular'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => TrackEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching popular tracks: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Playlists
  // ─────────────────────────────────────────────
  static Future<List<PlaylistEntity>> fetchPlaylists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/playlists'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => PlaylistEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching playlists: $e');
    }
    return [];
  }

  /// Returns raw JSON maps so the sync layer can read trackIds.
  static Future<List<Map<String, dynamic>>> fetchPlaylistsRaw() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/playlists'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching playlists raw: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Hero slides (home 16:9 carousel)
  // ─────────────────────────────────────────────
  static Future<List<HeroSlideEntity>> fetchHeroSlides() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hero-slides?isActive=true'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => HeroSlideEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching hero slides: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Videos (YouTube embeds for the home MTV row)
  // ─────────────────────────────────────────────
  static Future<List<VideoEntity>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/videos?isPublished=true'), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => VideoEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Chat messages
  // ─────────────────────────────────────────────
  static Future<List<ChatMessageEntity>> fetchChatMessages({int? beforeTimestamp, int limit = 20}) async {
    try {
      String url = '$baseUrl/chat/messages?limit=$limit';
      if (beforeTimestamp != null) {
        url += '&before=$beforeTimestamp';
      }
      final response = await http.get(Uri.parse(url), headers: AuthService.agentHeaders()).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => ChatMessageEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
    }
    return [];
  }

  static Future<bool> createChatMessage(ChatMessageEntity msg) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages'),
        headers: AuthService.publicHeaders(),
        body: json.encode(msg.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating chat message: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Playlists CRUD
  // ─────────────────────────────────────────────
  static Future<bool> createPlaylist(PlaylistEntity playlist) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/playlists'),
        headers: AuthService.publicHeaders(),
        body: json.encode(playlist.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating playlist: $e');
      return false;
    }
  }

  static Future<bool> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/playlists/$playlistId/tracks'),
        headers: AuthService.publicHeaders(),
        body: json.encode({'trackId': trackId}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error adding track to playlist: $e');
      return false;
    }
  }

  static Future<bool> removeTrackFromPlaylist(String playlistId, String trackId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/playlists/$playlistId/tracks/$trackId'),
        headers: AuthService.agentHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing track from playlist: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Play count
  // ─────────────────────────────────────────────
  static Future<void> incrementPlayCount(String trackId) async {
    try {
      // Logged-in plays carry the token so the backend records a verified
      // PlayEvent (1/user/track/day) for owner earnings. Guests still
      // move the raw popularity counter.
      final token = await AuthService.getToken();
      await http
          .post(
            Uri.parse('$baseUrl/tracks/$trackId/play'),
            headers: token == null
                ? AuthService.agentHeaders()
                : {'Authorization': 'Bearer $token', 'User-Agent': AuthService.appUserAgent},
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Fire-and-forget — do not block playback on network errors
      print('Error incrementing play count for $trackId: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Albums / Tracks CRUD (for contribute feature)
  // ─────────────────────────────────────────────
  static Future<bool> createAlbum(AlbumEntity album) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/albums'),
        headers: AuthService.publicHeaders(),
        body: json.encode(album.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating album: $e');
      return false;
    }
  }

  static Future<bool> createTrack(TrackEntity track) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracks'),
        headers: AuthService.publicHeaders(),
        body: json.encode(track.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating track: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Owner onboarding requests (pending admin review)
  // ─────────────────────────────────────────────
  static const int maxAvatarFileBytes = 5 * 1024 * 1024;

  static Future<void> submitOwnerRequest({
    required String name,
    required String ownerModel,
    required String phone,
    required String description,
    required String requesterName,
    required String requesterPhone,
    required List<String> videoLinks,
    required String avatarPath,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/owner-requests'));
    req.headers['User-Agent'] = AuthService.appUserAgent;
    req.fields['name'] = name;
    req.fields['ownerModel'] = ownerModel;
    req.fields['phone'] = phone;
    req.fields['description'] = description;
    req.fields['requesterName'] = requesterName;
    req.fields['requesterPhone'] = requesterPhone;
    req.fields['videoLinks'] = json.encode(videoLinks);
    req.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final body = await http.Response.fromStream(streamed);
    if (streamed.statusCode != 201) {
      String message = 'Request failed (${streamed.statusCode})';
      try {
        final decoded = json.decode(body.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  // ─────────────────────────────────────────────
  // Community contributions (pending admin review)
  // ─────────────────────────────────────────────
  static const int maxContributionFileBytes = 15 * 1024 * 1024;

  static Future<void> submitContribution({
    required String title,
    required String artistName,
    required String composerName,
    required int durationSeconds,
    required String audioPath,
    String? karaokePath,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Please log in first');

    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/contributions'));
    req.headers['User-Agent'] = AuthService.appUserAgent;
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['title'] = title;
    req.fields['artistName'] = artistName;
    req.fields['composerName'] = composerName;
    req.fields['durationSeconds'] = durationSeconds.toString();
    req.files.add(await http.MultipartFile.fromPath('audio', audioPath));
    if (karaokePath != null) {
      req.files.add(await http.MultipartFile.fromPath('karaoke', karaokePath));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 120));
    final body = await http.Response.fromStream(streamed);
    await AuthService.checkRevoked(body);
    if (streamed.statusCode != 201) {
      String message = 'Upload failed (${streamed.statusCode})';
      try {
        final decoded = json.decode(body.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
