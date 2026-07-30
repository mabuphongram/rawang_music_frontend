import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rawang_melodies/data/local/entity/entities.dart';

class ApiService {
  // Using the computer's local IP address so it works on a physical Android phone over Wi-Fi
  static const String baseUrl = 'http://192.168.90.31:5000/api';

  static Future<List<AlbumEntity>> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/albums'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlbumEntity.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching albums: \$e');
    }
    return [];
  }

  static Future<List<TrackEntity>> fetchTracks() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/tracks'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TrackEntity.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching tracks: \$e');
    }
    return [];
  }

  static Future<List<PlaylistEntity>> fetchPlaylists() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/playlists'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PlaylistEntity.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching playlists: \$e');
    }
    return [];
  }

  static Future<List<ChatMessageEntity>> fetchChatMessages() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/chat/messages'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessageEntity.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching chat messages: \$e');
    }
    return [];
  }

  static Future<bool> createChatMessage(ChatMessageEntity msg) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/chat/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(msg.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating chat message: \$e');
      return false;
    }
  }

  static Future<bool> createPlaylist(PlaylistEntity playlist) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/playlists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(playlist.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating playlist: \$e');
      return false;
    }
  }

  static Future<bool> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/playlists/\$playlistId/tracks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'trackId': trackId}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error adding track to playlist: \$e');
      return false;
    }
  }

  static Future<bool> removeTrackFromPlaylist(String playlistId, String trackId) async {
    try {
      final response = await http.delete(
        Uri.parse('\$baseUrl/playlists/\$playlistId/tracks/\$trackId'),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing track from playlist: \$e');
      return false;
    }
  }

  static Future<bool> createAlbum(AlbumEntity album) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/albums'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(album.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating album: \$e');
      return false;
    }
  }

  static Future<bool> createTrack(TrackEntity track) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/tracks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(track.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating track: \$e');
      return false;
    }
  }
}
