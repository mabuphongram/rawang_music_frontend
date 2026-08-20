import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';

class ChatViewModel extends ChangeNotifier {
  List<ChatMessageEntity> messages = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  IO.Socket? socket;

  ChatViewModel() {
    loadInitialMessages();
    _initSocket();
  }

  void _initSocket() {
    final socketUrl = ApiService.baseUrl.replaceAll('/api', '');
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket?.connect();

    socket?.onConnect((_) {
      print('Connected to Socket.IO server for chat');
    });

    socket?.on('new_message', (data) {
      if (data != null) {
        final newMessage = ChatMessageEntity.fromMap(data);
        
        // Ensure no duplicates by ID before adding
        final exists = messages.any((msg) => msg.id == newMessage.id);
        if (!exists) {
          // Socket messages are pushed, we append to the bottom 
          // (which is at the end of the list in this logic).
          messages.add(newMessage);
          notifyListeners();
        }
      }
    });

    socket?.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  Future<void> loadInitialMessages() async {
    isLoading = true;
    notifyListeners();

    messages = await ApiService.fetchChatMessages(limit: 20);
    hasMoreMessages = messages.length == 20;
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore || !hasMoreMessages || messages.isEmpty) return;

    isLoadingMore = true;
    notifyListeners();

    final beforeTimestamp = messages.first.timestamp;
    final olderMessages = await ApiService.fetchChatMessages(beforeTimestamp: beforeTimestamp, limit: 20);

    if (olderMessages.isNotEmpty) {
      messages.insertAll(0, olderMessages);
      hasMoreMessages = olderMessages.length == 20;
    } else {
      hasMoreMessages = false;
    }

    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> sendMessage(
    String senderName,
    String messageText,
  ) async {
    if (messageText.trim().isEmpty) return;

    final newMessage = ChatMessageEntity(
      id: "msg_user_${DateTime.now().millisecondsSinceEpoch}",
      senderName: senderName.isEmpty ? "User" : senderName,
      message: messageText,
      isUser: false,
    );

    final success = await ApiService.createChatMessage(newMessage);
    if (!success) {
      print('Failed to send message.');
    }
  }
}
