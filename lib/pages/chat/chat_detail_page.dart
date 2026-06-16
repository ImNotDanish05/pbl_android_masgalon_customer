import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart'; 
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _scrollController = ScrollController();
  final _chatService = ChatService(); // 👈 Inisialisasi Service

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Handle send sekarang mengirim data ke Supabase
  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Mengirim pesan ke database. Asumsi widget.chat.id adalah order_id
      await _chatService.kirimPesan(
        orderId: widget.chat.id, 
        teksPesan: text,
      );
      // Tidak perlu setState karena StreamBuilder akan otomatis mendeteksi pesan baru
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage(widget.chat.kurirAvatar),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                if (widget.chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.kurirName.split('–').first.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.chat.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.chat.isOnline ? Colors.green : Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 👇 Ganti Expanded biasa dengan StreamBuilder
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              // Dengarkan perubahan data berdasarkan order_id
              stream: _chatService.getChatStream(widget.chat.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                // Auto-scroll saat ada pesan baru masuk
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesan. Sapa kurirmu!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[index];
                    final prevMessage = index > 0 ? messages[index - 1] : null;
                    final showTime = prevMessage == null || 
                        _formatTime(prevMessage.time) != _formatTime(message.time);

                    return Column(
                      children: [
                        if (showTime && !message.isFromMe)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatTime(message.time), // 👈 Format waktu
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ),
                        MessageBubble(message: message), 
                        if (showTime && message.isFromMe)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatTime(message.time), // 👈 Format waktu
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          ChatInputBar(onSend: _handleSend),
        ],
      ),
    );
  }
}