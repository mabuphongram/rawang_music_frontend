import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

void showCreatePlaylistDialog(
  BuildContext context,
  void Function(String name, String description) onCreate,
) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Create New Playlist"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Playlist Name")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description (Optional)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                onCreate(nameCtrl.text, descCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}

void showAddToPlaylistDialog(
  BuildContext context,
  TrackEntity track,
  List<PlaylistEntity> playlists,
  void Function(String playlistId, String trackId) onAdd,
  VoidCallback onCreateNewPlaylist,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Add '${track.title}' to Playlist"),
        content: SizedBox(
          width: double.maxFinite,
          child: playlists.isEmpty
              ? const Text("You don't have any playlists yet.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(playlist.name),
                      onTap: () {
                        onAdd(playlist.id, track.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onCreateNewPlaylist();
            },
            child: const Text("New Playlist"),
          ),
        ],
      );
    },
  );
}

void showShareDialog(
  BuildContext context,
  TrackEntity track,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Share Track"),
        content: Text("Share '${track.title}' by ${track.artistName} with your friends!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ElevatedButton(
            onPressed: () {
              // Simulated share action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Link copied to clipboard!")),
              );
              Navigator.pop(context);
            },
            child: const Text("Copy Link"),
          ),
        ],
      );
    },
  );
}
