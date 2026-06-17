import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/chat_model.dart';
import '../widgets/shared/date_format.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi untuk MENDENGARKAN pesan secara Real-Time
  Stream<List<MessageModel>> getChatStream(String orderId) {
    final myUserId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('created_at', ascending: true)
        // 👇 Di sinilah keajaibannya: Mengubah data raw DB jadi List<MessageModel>
        .map(
          (dataList) => dataList
              .map((item) => MessageModel.fromJson(item, myUserId))
              .toList(),
        );
  }

  // 2. Fungsi untuk MENGIRIM pesan
  Future<void> kirimPesan({
    required String orderId,
    required String teksPesan,
  }) async {
    final myUserId = _supabase.auth.currentUser!.id;

    await _supabase.from('chats').insert({
      'order_id': orderId,
      'sender_id': myUserId,
      'message': teksPesan,
      // 'image_url': null, // Tambahkan nanti kalau ada fitur kirim gambar
    });
  }

  Future<List<ChatModel>> getDaftarChat() async {
    final myUserId = _supabase.auth.currentUser!.id;

    try {
      // TARIKAN NAFAS PANJANG: orders -> couriers -> users
      final response = await _supabase
          .from('orders')
          .select('''
            id,
            created_at,
            couriers (
              nama_asli,
              users (
                username,
                avatar_url
              )
            ),
            chats (message, created_at)
          ''')
          .eq('customer_id', myUserId)
          .neq('status', 'Selesai')
          .neq('status', 'Tolak')
          .order('created_at', ascending: false);

      final List<ChatModel> chatList = [];

      for (var order in response) {
        // Cek apakah pesanan ini sudah ada kurirnya
        if (order['couriers'] != null) {
          final courierData = order['couriers'];
          final userData = courierData['users'] ?? {};

          // Kita prioritaskan ambil username, kalau kosong pakai nama_asli kurir
          final String namaKurir =
              userData['username'] ??
              courierData['nama_asli'] ??
              'Menunggu Kurir';
          final String avatarKurir = userData['avatar_url'] ?? '';

          final List chats = order['chats'] ?? [];
          chats.sort(
            (a, b) => DateTime.parse(
              b['created_at'],
            ).compareTo(DateTime.parse(a['created_at'])),
          );
          final String lastMessage = chats.isNotEmpty
              ? chats.first['message']
              : 'Belum ada pesan';

          chatList.add(
            ChatModel(
              id: order['id'].toString(),
              kurirName: namaKurir,
              kurirAvatar: avatarKurir,
              lastMessage: lastMessage,
              time: chats.isNotEmpty
                  ? DateTime.parse(chats.first['created_at']).formattedTime
                  : '',
              isOnline: true, // Nanti diurus kalau fitur presence aktif
            ),
          );
        }
      }
      return chatList;
    } catch (e) {
      debugPrint('Error getDaftarChat: $e');
      return [];
    }
  }

  Future<void> kirimGambar({
    required String orderId,
    required String imagePath,
  }) async {
    final myUserId = _supabase.auth.currentUser!.id;
    final file = File(imagePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final pathSimpan = '$orderId/$fileName';

    try {
      // 1. Upload file fisik ke Supabase Storage (Bucket bernama 'chat_images')
      await _supabase.storage.from('chat_images').upload(pathSimpan, file);

      // 2. Ambil link URL publik dari gambar yang baru diupload
      final String imageUrl = _supabase.storage
          .from('chat_images')
          .getPublicUrl(pathSimpan);

      // 3. Simpan link tersebut ke tabel chats
      await _supabase.from('chats').insert({
        'order_id': orderId,
        'sender_id': myUserId,
        'message': '📷 Mengirim gambar', // Teks default jika ada gambarnya
        'image_url': imageUrl,
      });
    } catch (e) {
      debugPrint('Error upload gambar: $e');
      rethrow; // Lempar error ke UI agar bisa dimunculkan SnackBar
    }
  }
}
