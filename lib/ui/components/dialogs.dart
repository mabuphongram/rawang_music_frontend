import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

void showAddSongDialog(
  BuildContext context,
  void Function(String title, String rawangTitle, String artist, String album, OwnerType ownerType, String genre, String lyrics, bool hasKaraoke) onSubmit,
) {
  final titleCtrl = TextEditingController();
  final rawangTitleCtrl = TextEditingController();
  final artistCtrl = TextEditingController();
  final albumCtrl = TextEditingController();
  OwnerType selectedOwner = OwnerType.singer;
  bool hasKaraoke = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Contribute Rawang Song"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Song Title (English/Burmese)")),
                  TextField(controller: rawangTitleCtrl, decoration: const InputDecoration(labelText: "Rawang Title")),
                  TextField(controller: artistCtrl, decoration: const InputDecoration(labelText: "Artist/Band Name")),
                  TextField(controller: albumCtrl, decoration: const InputDecoration(labelText: "Album Name (Optional)")),
                  DropdownButtonFormField<OwnerType>(
                    value: selectedOwner,
                    items: OwnerType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedOwner = val);
                    },
                    decoration: const InputDecoration(labelText: "Owner Type"),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: hasKaraoke,
                        onChanged: (val) {
                          if (val != null) setState(() => hasKaraoke = val);
                        },
                      ),
                      const Text("Include Instrumental/Karaoke"),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    onSubmit(
                      titleCtrl.text,
                      rawangTitleCtrl.text,
                      artistCtrl.text,
                      albumCtrl.text,
                      selectedOwner,
                      "Cultural",
                      "Added by community",
                      hasKaraoke,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      );
    },
  );
}

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
