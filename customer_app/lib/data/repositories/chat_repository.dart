import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../services/supabase/supabase_service.dart';
import '../models/message_model.dart';

class ChatRepository {
  ChatRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<List<MessageModel>>> getMessages(
    String bookingId, {
    int? limit,
    int? offset,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'messages',
        filters: {'booking_id': bookingId},
        orderBy: 'created_at',
        ascending: true,
        limit: limit,
        offset: offset,
      );
      return data.map((json) => MessageModel.fromJson(json)).toList();
    });
  }

  Future<Result<MessageModel>> sendMessage(MessageModel message) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.insert('messages', message.toJson());
      return MessageModel.fromJson(data);
    });
  }

  RealtimeChannel subscribeToMessages(
    String bookingId,
    void Function(MessageModel message) onMessage,
  ) {
    return SupabaseService.client
        .channel('messages:$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: bookingId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();
  }

  Future<Result<void>> markAsRead(String messageId) async {
    return ErrorHandler.guard(() async {
      await apiClient.update('messages', messageId, {'is_read': true});
    });
  }

  void unsubscribe(RealtimeChannel channel) {
    SupabaseService.client.removeChannel(channel);
  }
}
