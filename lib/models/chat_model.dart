// lib/models/chat_model.dart

enum MessageType { text, statusPengiriman, image }
enum MessageStatus { sent, delivered, read }

// ==========================================
// 1. MODEL UNTUK INFO KURIR & DAFTAR CHAT
// ==========================================
class ChatModel {
  final String id; // Ini akan diisi dengan order_id
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

// ==========================================
// 2. MODEL UNTUK GELEMBUNG PESAN (DARI DATABASE)
// ==========================================
class MessageModel {
  final String id;
  final String orderId; 
  final String text;
  final bool isFromMe;  
  final DateTime time;  
  final MessageType type;
  final String? imageUrl; 

  // Untuk fitur opsional
  final String? deliveryTitle;
  final String? deliverySubtitle;
  final String? deliveryBadge;

  const MessageModel({
    required this.id,
    required this.orderId,
    required this.text,
    required this.isFromMe,
    required this.time,
    this.type = MessageType.text,
    this.imageUrl,
    this.deliveryTitle,
    this.deliverySubtitle,
    this.deliveryBadge,
  });

  // Fungsi sakti untuk mengubah data dari Supabase jadi MessageModel
  factory MessageModel.fromJson(Map<String, dynamic> json, String myUserId) {
    final bool isMe = json['sender_id'] == myUserId;
    final bool hasImage = json['image_url'] != null;

    return MessageModel(
      id: json['id'].toString(), // Supabase UUID biasanya string
      orderId: json['order_id'].toString(),
      text: json['message'] ?? '',
      isFromMe: isMe,
      time: DateTime.parse(json['created_at']),
      type: hasImage ? MessageType.image : MessageType.text,
      imageUrl: json['image_url'],
    );
  }
}