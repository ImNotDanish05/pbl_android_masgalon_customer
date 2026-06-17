import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../models/chat_model.dart';
import '../widgets/shared/date_format.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi untuk MENDENGARKAN pesan secara Real-Time
  Stream<List<MessageModel>> getChatStream(String orderId) {
    final controller = StreamController<List<MessageModel>>();
    final myUserId = _supabase.auth.currentUser!.id;

    // Fungsi untuk mengambil data chat + gambar secara lengkap
    Future<void> fetchLengkap() async {
      try {
        final response = await _supabase
            .from('chats')
            .select('*, chat_images(image_url)')
            .eq('order_id', orderId)
            .order('created_at', ascending: true);

        final messages = List<Map<String, dynamic>>.from(
          response,
        ).map((json) => MessageModel.fromJson(json, myUserId)).toList();

        if (!controller.isClosed) controller.add(messages);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    // Jalankan fetch pertama kali saat halaman dibuka
    fetchLengkap();

    // Dengarkan secara realtime jika ada data baru masuk ke tabel chats
    final channel = _supabase
        .channel('realtime_chats_$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'order_id',
            value: orderId,
          ),
          callback: (payload) {
            fetchLengkap(); // 👈 Setiap ada chat baru, panggil fungsi fetch ulang data lengkapnya
          },
        );

    channel.subscribe();

    // Tutup channel jika user keluar dari halaman chat
    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
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

  // Tambahkan 'required String pesanTeks' di dalam kurungnya
  Future<void> kirimBanyakGambar({
    required String orderId,
    required List<XFile> images,
    required String pesanTeks,
  }) async {
    final myUserId = _supabase.auth.currentUser!.id;
    final imagePaths = images;

    try {
      // A. Simpan teks/caption dulu ke tabel chats, ambil ID chat barunya
      final String finalMessage = pesanTeks.isNotEmpty
          ? pesanTeks
          : '📷 Mengirim ${imagePaths.length} gambar';

      final chatResponse = await _supabase
          .from('chats')
          .insert({
            'order_id': orderId,
            'sender_id': myUserId,
            'message': finalMessage,
          })
          .select('id')
          .single();

      final String chatId = chatResponse['id'].toString();

      // B. Upload file fisik ke Storage Bucket & catat ke tabel chat_images satu per satu
      for (final (index, image) in imagePaths.indexed) {
        final imageBytes = await image.readAsBytes();
        final originalName = image.name.isNotEmpty
            ? image.name
            : image.path.split(RegExp(r'[/\\]')).last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${index}_$originalName';
        final pathSimpan = '$orderId/$fileName';

        // 1. Upload ke Storage
        await _supabase.storage
            .from('chat_images')
            .uploadBinary(
              pathSimpan,
              imageBytes,
              fileOptions: const FileOptions(cacheControl: '3600'),
            );
        final String imageUrl = _supabase.storage
            .from('chat_images')
            .getPublicUrl(pathSimpan);

        // 2. Catat ke tabel chat_images milik temanmu
        await _supabase.from('chat_images').insert({
          'chat_id': chatId, // Sambungkan ke ID chat utama
          'image_url': imageUrl,
        });
      }
    } catch (e) {
      debugPrint('Error kirim gambar: $e');
      rethrow;
    }
  }
}
