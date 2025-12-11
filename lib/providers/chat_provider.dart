import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:reminder_app/models/message_model.dart';
import 'package:reminder_app/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  bool _isLoading = false;
  String? _error;
  String? _currentFamilyId;

  // Getters
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Start listening to messages for a family
  void listenToMessages(String familyId) {
    // Avoid re-subscribing if already listening to same family
    if (_currentFamilyId == familyId && _messagesSubscription != null) {
      return;
    }

    // Cancel previous subscription if exists
    _messagesSubscription?.cancel();
    _currentFamilyId = familyId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _messagesSubscription = _chatService
        .getMessages(familyId)
        .listen(
          (messages) {
            _messages = messages;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
            debugPrint('ChatProvider stream error: $e');
          },
        );
  }

  /// Send a new message
  Future<void> sendMessage({
    required String text,
    required String senderName,
    String? senderPhotoUrl,
    String type = 'text',
    String? mediaUrl,
  }) async {
    if (_currentFamilyId == null) {
      _error = 'No family selected';
      notifyListeners();
      return;
    }

    try {
      await _chatService.sendMessage(
        familyId: _currentFamilyId!,
        text: text,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: type,
        mediaUrl: mediaUrl,
      );
      // No need to manually add message - stream will update automatically
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(String messageId) async {
    if (_currentFamilyId == null) return;
    await _chatService.markAsRead(_currentFamilyId!, messageId);
  }

  /// Stop listening to messages (call when leaving chat screen)
  void stopListening() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentFamilyId = null;
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
