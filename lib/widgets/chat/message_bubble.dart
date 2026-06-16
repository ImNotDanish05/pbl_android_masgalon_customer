import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../shared/date_format.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});


  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.statusPengiriman:
        return _StatusPengirimanBubble(message: message, timeText: (message.time.timeZoneName));
      case MessageType.image:
        return _ImageBubble(message: message, timeText: message.time.formattedTime);
      case MessageType.text:
        return _TextBubble(message: message, timeText: message.time.formattedTime);
    }
  }
}

// ── Text bubble ───────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final MessageModel message;
  final String timeText;
  
  const _TextBubble({required this.message, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isFromMe ? AppColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
            bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                color: message.isFromMe ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText, // 👈 Pakai timeText yang sudah di-format
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isFromMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[400],
                  ),
                ),
                // Karena di database temanmu tidak ada fitur "read receipt" (centang biru), 
                // kita asumsikan semua pesan terkirim.
                if (message.isFromMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done, // Centang satu (terkirim)
                    size: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Pengiriman bubble ──────────────────────────────────
class _StatusPengirimanBubble extends StatelessWidget {
  final MessageModel message;
  final String timeText;
  
  const _StatusPengirimanBubble({required this.message, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon truk
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_outlined,
                  color: Color(0xFFE07B00), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.deliveryTitle ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    message.deliverySubtitle ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (message.deliveryBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B00),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  message.deliveryBadge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Image bubble ──────────────────────────────────────────────
class _ImageBubble extends StatelessWidget {
  final MessageModel message;
  final String timeText;
  
  const _ImageBubble({required this.message, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: message.isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: message.imageUrl != null // 👈 Ubah dari imageAsset jadi imageUrl
                  ? Image.network( // 👈 Pakai Image.network karena gambar dari Supabase Storage adalah URL
                      message.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey, size: 48),
                      ),
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image,
                          color: Colors.grey, size: 48),
                    ),
            ),
            const SizedBox(height: 6),
            // Caption
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty) ...[
                    Text(
                      message.text,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    timeText, // 👈 Pakai timeText
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
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