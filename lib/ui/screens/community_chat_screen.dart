import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

class CommunityChatScreen extends StatefulWidget {
  final List<ChatMessageEntity> messages;
  final List<TrackEntity> allTracks;
  final TrackEntity? currentPlayingTrack;
  final void Function(String senderName, String messageText, String? trackId, String? trackTitle) onSendMessage;
  final void Function(String) onPlayTrackById;

  const CommunityChatScreen({
    super.key,
    required this.messages,
    required this.allTracks,
    this.currentPlayingTrack,
    required this.onSendMessage,
    required this.onPlayTrackById,
  });

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _attachCurrentTrack = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant CommunityChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(int timestamp) {
    return DateFormat('HH:mm, MMM d').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people, color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rawang Community Chat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    "Connect with Rawang music lovers & share song suggestions",
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final msg = widget.messages[index];
              final isUser = msg.isUser;

              return Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "${msg.senderName} • ${_formatTimestamp(msg.timestamp)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (msg.attachedTrackTitle != null && msg.attachedTrackTitle!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              if (msg.attachedTrackId != null) {
                                widget.onPlayTrackById(msg.attachedTrackId!);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? theme.colorScheme.onPrimary.withOpacity(0.2)
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      msg.attachedTrackTitle!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimaryContainer,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.play_arrow,
                                    color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (widget.currentPlayingTrack != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _attachCurrentTrack = !_attachCurrentTrack;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _attachCurrentTrack ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _attachCurrentTrack
                            ? "Attached: ${widget.currentPlayingTrack!.title}"
                            : "Tap to attach current song: ${widget.currentPlayingTrack!.title}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 90),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Your Name (e.g., Ah Dang)",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type message to Rawang people...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(
        _nameController.text.trim(),
        _messageController.text.trim(),
        _attachCurrentTrack ? widget.currentPlayingTrack?.id : null,
        _attachCurrentTrack ? widget.currentPlayingTrack?.title : null,
      );
      _messageController.clear();
      setState(() {
        _attachCurrentTrack = false;
      });
    }
  }
}
