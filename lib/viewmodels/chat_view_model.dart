import 'package:flutter/foundation.dart';
import 'package:rawang_melodies/data/local/database_helper.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

class ChatViewModel extends ChangeNotifier {
  final DatabaseHelper db = DatabaseHelper.instance;

  List<ChatMessageEntity> messages = [];

  ChatViewModel() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    messages = await db.getAllMessages();
    notifyListeners();
  }

  Future<void> sendMessage(
    String senderName,
    String messageText,
    String? trackId,
    String? trackTitle,
  ) async {
    if (messageText.trim().isEmpty && trackId == null) return;

    final newMessage = ChatMessageEntity(
      id: "msg_user_\${DateTime.now().millisecondsSinceEpoch}",
      senderName: senderName.isEmpty ? "User" : senderName,
      message: messageText,
      attachedTrackId: trackId,
      attachedTrackTitle: trackTitle,
      isUser: true,
    );

    await db.insertMessage(newMessage);
    await _loadMessages();
  }
}
