import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/shared/custom_app_bar.dart';
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
  final _chatService = ChatService();
  bool _isUploadingImage = false;

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

  void _showImagePickerOptions(String teksAwal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kirim Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F1FF),
                  child: Icon(Icons.photo_library, color: AppColors.darkBlue),
                ),
                title: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.gallery, teksAwal);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F1FF),
                  child: Icon(Icons.camera_alt, color: AppColors.darkBlue),
                ),
                title: const Text(
                  'Ambil Foto (Kamera)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.camera, teksAwal);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // 👇 FUNGSI BARU 2: Logika memilih gambar dan melempar ke halaman Preview
  Future<void> _pickAndSendImage(ImageSource source, String teksAwal) async {
    final ImagePicker picker = ImagePicker();
    try {
      List<XFile> pickedFiles = [];

      // Buka galeri atau kamera
      if (source == ImageSource.gallery) {
        pickedFiles = await picker.pickMultiImage(imageQuality: 70);
      } else {
        final XFile? file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (file != null) pickedFiles.add(file);
      }

      if (pickedFiles.isEmpty) return;
      if (!mounted) return;

      // Lempar ke halaman Preview yang baru kita buat di bawah
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImagePreviewPage(images: pickedFiles, initialCaption: teksAwal),
        ),
      );

      // Jika user menekan tombol 'Back' di halaman preview (Batal kirim)
      if (result == null || result['confirmed'] != true) return;

      // Ambil caption dari halaman preview
      final String caption = result['caption'] as String? ?? '';

      setState(() => _isUploadingImage = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mengunggah ${pickedFiles.length} gambar...')),
      );

      // Panggil service yang sudah menggunakan struktur Array dari pesan sebelumnya
      await _chatService.kirimBanyakGambar(
        orderId: widget.chat.id,
        images: pickedFiles,
        pesanTeks: caption,
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim gambar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // Handle send sekarang mengirim data ke Supabase
  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Mengirim pesan ke database. Asumsi widget.chat.id adalah order_id
      await _chatService.kirimPesan(orderId: widget.chat.id, teksPesan: text);
      // Tidak perlu setState karena StreamBuilder akan otomatis mendeteksi pesan baru
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
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
      appBar: CustomAppBar(
        showLogo: false,
        showNotifications: false,
        showBackButton: true,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.kurirName.split('–').first.trim(),
              style: const TextStyle(
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
      ),
      body: Column(
        children: [
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
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesan. Sapa kurirmu!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[index];
                    final prevMessage = index > 0 ? messages[index - 1] : null;
                    final showTime =
                        prevMessage == null ||
                        _formatTime(prevMessage.time) !=
                            _formatTime(message.time);

                    return Column(
                      children: [
                        if (showTime && !message.isFromMe)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatTime(message.time), // 👈 Format waktu
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        MessageBubble(message: message),
                        if (showTime && message.isFromMe)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatTime(message.time), // 👈 Format waktu
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          ChatInputBar(onSend: _handleSend, onAttach: _showImagePickerOptions),
        ],
      ),
    );
  }
}

class ImagePreviewPage extends StatefulWidget {
  final List<XFile> images;
  final String initialCaption;

  const ImagePreviewPage({
    super.key,
    required this.images,
    this.initialCaption= '',
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final TextEditingController _captionController = TextEditingController();
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _captionController.text= widget.initialCaption;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagesCount = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          imagesCount > 1 ? 'Kirim $imagesCount Foto' : 'Kirim Foto',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imagesCount,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: _PreviewImage(image: widget.images[index]),
                      );
                    },
                  ),
                  if (imagesCount > 1)
                    Positioned(
                      bottom: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          imagesCount,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.black87,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan keterangan...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'confirmed': true,
                        'caption': _captionController.text.trim(),
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.darkBlue, // Sesuaikan warna birumu
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  final XFile image;

  const _PreviewImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 56,
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.contain,
        );
      },
    );
  }
}