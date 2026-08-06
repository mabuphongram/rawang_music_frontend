import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rawang_melodies/data/local/entity/entities.dart';

class ApiService {
  // Local IP so physical Android device can reach the dev server over Wi-Fi
  static const String baseUrl = 'http://79.143.177.76:5000/api';

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
      final singersRes = await http.get(Uri.parse('$baseUrl/singers'));
      if (singersRes.statusCode == 200) {
        final List<dynamic> data = json.decode(singersRes.body);
        for (final j in data) {
          results.add(OwnerEntity.fromMap(j, ownerType: 'singer'));
        }
      }
    } catch (e) {
      print('Error fetching singers: $e');
    }
    try {
      final orgsRes = await http.get(Uri.parse('$baseUrl/organizations'));
      if (orgsRes.statusCode == 200) {
        final List<dynamic> data = json.decode(orgsRes.body);
        for (final j in data) {
          results.add(OwnerEntity.fromMap(j, ownerType: 'organization'));
        }
      }
    } catch (e) {
      print('Error fetching organizations: $e');
    }
    return results;
  }

  // ─────────────────────────────────────────────
  // Albums
  // ─────────────────────────────────────────────
  static Future<List<AlbumEntity>> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/albums'));
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
      final response = await http.get(Uri.parse('$baseUrl/tracks'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => TrackEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Playlists
  // ─────────────────────────────────────────────
  static Future<List<PlaylistEntity>> fetchPlaylists() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/playlists'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => PlaylistEntity.fromMap(j)).toList();
      }
    } catch (e) {
      print('Error fetching playlists: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────
  // Chat messages
  // ─────────────────────────────────────────────
  static Future<List<ChatMessageEntity>> fetchChatMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/messages'));
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing track from playlist: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Albums / Tracks CRUD (for contribute feature)
  // ─────────────────────────────────────────────
  static Future<bool> createAlbum(AlbumEntity album) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/albums'),
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode(track.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating track: $e');
      return false;
    }
  }
}
