import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;
import 'package:uuid/uuid.dart';

import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../services/ai/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required this.chatRepository,
    required this.aiService,
  });

  final ChatRepository chatRepository;
  final AiService aiService;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  RealtimeChannel? _channel;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessages(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    final result = await chatRepository.getMessages(bookingId);
    result.when(
      success: (messages) {
        _messages = messages;
        _isLoading = false;
      },
      failure: (e) {
        _errorMessage = e.message;
        _isLoading = false;
      },
    );
    notifyListeners();

    // Subscribe to realtime updates
    _subscribeToMessages(bookingId);
  }

  void _subscribeToMessages(String bookingId) {
    _unsubscribe();
    _channel = chatRepository.subscribeToMessages(
      bookingId,
      (message) {
        if (!_messages.any((m) => m.id == message.id)) {
          _messages = [..._messages, message];
          notifyListeners();
        }
      },
    );
  }

  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) async {
    _isSending = true;
    notifyListeners();

    final message = MessageModel(
      id: const Uuid().v4(),
      bookingId: bookingId,
      senderId: senderId,
      senderType: MessageSender.user,
      messageType: type,
      content: content,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );

    final result = await chatRepository.sendMessage(message);
    result.when(
      success: (sent) {
        _isSending = false;
      },
      failure: (e) {
        _errorMessage = e.message;
        _isSending = false;
      },
    );
    notifyListeners();
  }

  Future<void> sendAiMessage({
    required String bookingId,
    required String userMessage,
    String? context,
    String? userId,
  }) async {
    _isSending = true;
    notifyListeners();

    final result = await aiService.chatWithAI(
      message: userMessage,
      conversationId: bookingId,
      context: context,
      userId: userId,
    );

    result.when(
      success: (response) {
        final aiMessage = MessageModel(
          id: const Uuid().v4(),
          bookingId: bookingId,
          senderId: 'ai_assistant',
          senderType: MessageSender.ai,
          messageType: MessageType.ai,
          content: response['response'] as String? ?? '',
          metadata: response,
          createdAt: DateTime.now(),
        );
        chatRepository.sendMessage(aiMessage);
        _isSending = false;
      },
      failure: (e) {
        _errorMessage = e.message;
        _isSending = false;
      },
    );
    notifyListeners();
  }

  void _unsubscribe() {
    if (_channel != null) {
      chatRepository.unsubscribe(_channel!);
      _channel = null;
    }
  }

  void clearMessages() {
    _messages = [];
    _unsubscribe();
    notifyListeners();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
