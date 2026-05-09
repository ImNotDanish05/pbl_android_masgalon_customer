import '../models/chat_model.dart';

class ChatDummyData {
  // ── CHAT LIST ──────────────────────────────────────────────
  static const List<ChatModel> chatList = [
    ChatModel(
      id: 'chat_1',
      kurirName: 'Andi – Kurir Mas Galon',
      kurirAvatar: 'assets/images/kurir_andi.png',
      lastMessage: 'Saya sudah di depan gerbang kak, mohon dibantu buka.',
      time: '10:45',
      unreadCount: 2,
      isOnline: true,
      lastMessageStatus: MessageStatus.delivered,
    ),
    ChatModel(
      id: 'chat_2',
      kurirName: 'Andi – Kurir Mas Galon',
      kurirAvatar: 'assets/images/kurir_andi2.png',
      lastMessage: 'Pesanan Galon Aqua (2x) telah selesai dikirim. Terima kasih!',
      time: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      lastMessageStatus: MessageStatus.read,
    ),
    ChatModel(
      id: 'chat_3',
      kurirName: 'Slamet – Kurir Mas Galon',
      kurirAvatar: 'assets/images/kurir_slamet.png',
      lastMessage: 'Siap pak, saya berangkat sekarang.',
      time: 'Monday',
      unreadCount: 0,
      isOnline: false,
      lastMessageStatus: MessageStatus.read,
    ),
  ];

  // ── MESSAGES PER CHAT ──────────────────────────────────────
  static const Map<String, List<MessageModel>> messages = {
    'chat_1': [
      MessageModel(
        id: 'm1',
        chatId: 'chat_1',
        text: 'Halo Kak, saya Andi dari Mas Galon. Saya sudah di depan gerbang perumahan ya.',
        isFromMe: false,
        time: '14:02',
        type: MessageType.text,
      ),
      MessageModel(
        id: 'm2',
        chatId: 'chat_1',
        text: 'Oke Pak Andi. Mohon tunggu sebentar ya, saya ambil kuncinya dulu.',
        isFromMe: true,
        time: '14:03',
        type: MessageType.text,
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm3',
        chatId: 'chat_1',
        text: '',
        isFromMe: false,
        time: '14:10',
        type: MessageType.statusPengiriman,
        deliveryTitle: 'Status Pengiriman',
        deliverySubtitle: '3 Galon Mineral (Pesan #MG-882)',
        deliveryBadge: 'SAMPAI',
      ),
      MessageModel(
        id: 'm4',
        chatId: 'chat_1',
        text: 'Galonnya saya taruh di teras ya Kak sesuai instruksi.',
        isFromMe: false,
        time: '14:15',
        type: MessageType.image,
        imageAsset: 'assets/images/delivery_photo.png',
      ),
      MessageModel(
        id: 'm5',
        chatId: 'chat_1',
        text: 'Sip Pak, terima kasih banyak!',
        isFromMe: true,
        time: '14:16',
        type: MessageType.text,
        status: MessageStatus.read,
      ),
    ],
    'chat_2': [
      MessageModel(
        id: 'm6',
        chatId: 'chat_2',
        text: 'Pesanan Galon Aqua (2x) telah selesai dikirim. Terima kasih!',
        isFromMe: false,
        time: 'Yesterday',
        type: MessageType.text,
      ),
    ],
    'chat_3': [
      MessageModel(
        id: 'm7',
        chatId: 'chat_3',
        text: 'Pak, pesanan saya kapan dikirim?',
        isFromMe: true,
        time: 'Monday',
        type: MessageType.text,
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm8',
        chatId: 'chat_3',
        text: 'Siap pak, saya berangkat sekarang.',
        isFromMe: false,
        time: 'Monday',
        type: MessageType.text,
      ),
    ],
  };
}
