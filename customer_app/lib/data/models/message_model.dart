enum MessageType { text, image, video, ai, system }

enum MessageSender { user, provider, ai, system }

class MessageModel {
  const MessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderType,
    required this.messageType,
    required this.content,
    this.attachmentUrl,
    this.metadata,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String bookingId;
  final String senderId;
  final MessageSender senderType;
  final MessageType messageType;
  final String content;
  final String? attachmentUrl;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime? createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      senderId: json['sender_id'] as String,
      senderType: MessageSender.values.firstWhere(
        (e) => e.name == json['sender_type'],
        orElse: () => MessageSender.user,
      ),
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['message_type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'sender_id': senderId,
      'sender_type': senderType.name,
      'message_type': messageType.name,
      'content': content,
      'attachment_url': attachmentUrl,
      'metadata': metadata,
      'is_read': isRead,
    };
  }
}
