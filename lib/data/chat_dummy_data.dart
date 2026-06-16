// import '../models/chat_model.dart';
// import '../../widgets/shared/date_format.dart';

// class ChatDummyData {
//   // ── CHAT LIST ──────────────────────────────────────────────
//   static  List<ChatModel> chatList = [
//     ChatModel(
//       id: 'chat_1',
//       kurirName: 'Andi – Kurir Mas Galon',
//       kurirAvatar: 'assets/images/kurir_andi.png',
//       lastMessage: 'Saya sudah di depan gerbang kak, mohon dibantu buka.',
//       time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//       unreadCount: 2,
//       isOnline: true,
//       lastMessageStatus: MessageStatus.delivered,
//     ),
//     ChatModel(
//       id: 'chat_2',
//       kurirName: 'Andi – Kurir Mas Galon',
//       kurirAvatar: 'assets/images/kurir_andi2.png',
//       lastMessage: 'Pesanan Galon Aqua (2x) telah selesai dikirim. Terima kasih!',
//       time: DateTime.now().subtract(const Duration(days: 1)).formattedTime,
//       unreadCount: 0,
//       isOnline: false,
//       lastMessageStatus: MessageStatus.read,
//     ),
//     ChatModel(
//       id: 'chat_3',
//       kurirName: 'Slamet – Kurir Mas Galon',
//       kurirAvatar: 'assets/images/kurir_slamet.png',
//       lastMessage: 'Siap pak, saya berangkat sekarang.',
//       time: DateTime.now().subtract(const Duration(days: 2)).formattedTime,
//       unreadCount: 0,
//       isOnline: false,
//       lastMessageStatus: MessageStatus.read,
//     ),
//   ];

//   // ── MESSAGES PER CHAT ──────────────────────────────────────
//   static Map<String, List<MessageModel>> messages = {
//     'chat_1': [
//       MessageModel(
//         id: 'm1',
//         orderId: 'chat_1',
//         text: 'Halo Kak, saya Andi dari Mas Galon. Saya sudah di depan gerbang perumahan ya.',
//         isFromMe: false,
//         time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//         type: MessageType.text,
//       ),
//       MessageModel(
//         id: 'm2',
//         orderId: 'chat_1',
//         text: 'Oke Pak Andi. Mohon tunggu sebentar ya, saya ambil kuncinya dulu.',
//         isFromMe: true,
//         time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//         type: MessageType.text,
//         status: MessageStatus.read,
//       ),
//       MessageModel(
//         id: 'm3',
//         orderId: 'chat_1',
//         text: '',
//         isFromMe: false,
//         time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//         type: MessageType.statusPengiriman,
//         deliveryTitle: 'Status Pengiriman',
//         deliverySubtitle: '3 Galon Mineral (Pesan #MG-882)',
//         deliveryBadge: 'SAMPAI',
//       ),
//       MessageModel(
//         id: 'm4',
//         orderId: 'chat_1',
//         text: 'Galonnya saya taruh di teras ya Kak sesuai instruksi.',
//         isFromMe: false,
//         time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//         type: MessageType.image,
//         imageAsset: 'assets/images/delivery_photo.png',
//       ),
//       MessageModel(
//         id: 'm5',
//         orderId: 'chat_1',
//         text: 'Sip Pak, terima kasih banyak!',
//         isFromMe: true,
//         time: DateTime.now().subtract(const Duration(hours: 2)).formattedTime,
//         type: MessageType.text,
//         status: MessageStatus.read,
//       ),
//     ],
//     'chat_2': [
//       MessageModel(
//         id: 'm6',
//         orderId: 'chat_2',
//         text: 'Pesanan Galon Aqua (2x) telah selesai dikirim. Terima kasih!',
//         isFromMe: false,
//         time: DateTime.now().subtract(const Duration(days: 1)).formattedTime,
//         type: MessageType.text,
//       ),
//     ],
//     'chat_3': [
//       MessageModel(
//         id: 'm7',
//         orderId: 'chat_3',
//         text: 'Pak, pesanan saya kapan dikirim?',
//         isFromMe: true,
//         time: DateTime.now().subtract(const Duration(days: 2)).formattedTime,
//         type: MessageType.text,
//         status: MessageStatus.read,
//       ),
//       MessageModel(
//         id: 'm8',
//         orderId: 'chat_3',
//         text: 'Siap pak, saya berangkat sekarang.',
//         isFromMe: false,
//         time: DateTime.now().subtract(const Duration(days: 2)).formattedTime,
//         type: MessageType.text,
//       ),
//     ],
//   };
// }
