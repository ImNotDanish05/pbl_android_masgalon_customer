enum MessageType { text, statusPengiriman, image }

enum MessageStatus { sent, delivered, read }

class ChatModel {
  final String id;
  final String kurirName;
  final String kurirAvatar;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final MessageStatus lastMessageStatus;

  const ChatModel({
    required this.id,
    required this.kurirName,
    required this.kurirAvatar,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastMessageStatus = MessageStatus.read,
  });
}

class MessageModel {
  final String id;
  final String chatId;
  final String text;
  final bool isFromMe;
  final String time;
  final MessageType type;
  final MessageStatus status;

  // Untuk tipe statusPengiriman
  final String? deliveryTitle;
  final String? deliverySubtitle;
  final String? deliveryBadge;

  // Untuk tipe image
  final String? imageAsset;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.text,
    required this.isFromMe,
    required this.time,
    this.type = MessageType.text,
    this.status = MessageStatus.read,
    this.deliveryTitle,
    this.deliverySubtitle,
    this.deliveryBadge,
    this.imageAsset,
  });
}
