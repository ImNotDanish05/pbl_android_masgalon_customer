import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/chat_dummy_data.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late List<MessageModel> _messages;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.from(
      ChatDummyData.messages[widget.chat.id] ?? [],
    );
    // Scroll ke bawah setelah build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

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

  void _handleSend(String text) {
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      text: text,
      isFromMe: true,
      time: _formatTime(DateTime.now()),
      type: MessageType.text,
      status: MessageStatus.sent,
    );

    setState(() => _messages.add(newMessage));

    // Scroll ke bawah setelah pesan baru
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
                  backgroundImage:
                      AssetImage(widget.chat.kurirAvatar),
                  onBackgroundImageError: (_, __) {},
                  child:
                      const Icon(Icons.person, color: Colors.white),
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
                        border:
                            Border.all(color: Colors.white, width: 2),
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
                    color: widget.chat.isOnline
                        ? Colors.green
                        : Colors.grey[400],
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
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final prevMessage =
                    index > 0 ? _messages[index - 1] : null;

                // Tampilkan timestamp jika beda waktu dari pesan sebelumnya
                final showTime = prevMessage == null ||
                    prevMessage.time != message.time;

                return Column(
                  children: [
                    if (showTime && !message.isFromMe)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          message.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    MessageBubble(message: message),
                    if (showTime && message.isFromMe)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          message.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Input bar
          ChatInputBar(onSend: _handleSend),
        ],
      ),
    );
  }
}
