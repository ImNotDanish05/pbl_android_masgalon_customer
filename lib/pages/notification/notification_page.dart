import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'semua';
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = ref.read(authCustomerProvider);
    if (user == null) {
      setState(() {
        _notifications = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      if (!mounted) return;

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });

      await _markAllAsRead(user.id, updateLocalState: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat notifikasi';
      });
    }
  }

  Future<void> _markAllAsRead(
    String userId, {
    bool updateLocalState = false,
  }) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      if (!mounted || !updateLocalState) return;
      setState(() {
        _notifications = _notifications
            .map((item) => {...item, 'is_read': true})
            .toList();
      });
    } catch (_) {
      // Keep the page usable even if the read-sync fails.
    }
  }

  Future<void> _markCurrentUserNotificationsAsRead() async {
    final user = ref.read(authCustomerProvider);
    if (user == null) return;
    await _markAllAsRead(user.id, updateLocalState: true);
  }

  Future<void> _deleteNotification(String id) async {
    final previous = List<Map<String, dynamic>>.from(_notifications);

    setState(() {
      _notifications.removeWhere((item) => item['id'].toString() == id);
    });

    try {
      await _supabase.from('notifications').delete().eq('id', id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notifications = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus notifikasi')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_activeFilter == 'semua') return _notifications;

    return _notifications.where((item) {
      final category = item['category']?.toString() ?? 'order';
      return category == _activeFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((item) => item['is_read'] != true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D52A1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: const Color(0xFF0D52A1),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D52A1)),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(unreadCount),
    );
  }

  Widget _buildBody(int unreadCount) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D52A1)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadNotifications, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('Semua', 'semua'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Pesanan', 'order'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Top Up', 'topup'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Chat', 'chat'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Voucher', 'voucher'),
                    ],
                  ),
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _markCurrentUserNotificationsAsRead,
                  child: const Text(
                    'Tandai Dibaca',
                    style: TextStyle(
                      color: Color(0xFF0D52A1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF0D52A1),
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      final notificationId = item['id'].toString();

                      return Dismissible(
                        key: Key(notificationId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await _deleteNotification(notificationId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi dihapus'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                        child: _buildNotificationCard(item),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isActive = _activeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D52A1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF0D52A1) : Colors.grey[200]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final isRead = item['is_read'] == true;
    final category = item['category']?.toString() ?? 'order';
    final title = item['title']?.toString() ?? '';
    final body = item['body']?.toString() ?? '';
    final createdAt = item['created_at']?.toString();
    final categoryColor = _categoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey[100]! : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(category), color: categoryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              isRead ? FontWeight.bold : FontWeight.w800,
                          color: isRead
                              ? Colors.black87
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D52A1),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isRead ? Colors.grey[600] : const Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
                if (createdAt != null && createdAt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Semua pemberitahuan pesanan dan top up Anda bersih.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'topup':
        return Icons.account_balance_wallet_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'voucher':
        return Icons.local_offer_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'topup':
        return Colors.teal;
      case 'chat':
        return const Color(0xFF7C3AED);
      case 'voucher':
        return Colors.orange[800]!;
      default:
        return const Color(0xFF0D52A1);
    }
  }

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(dateTime);
    } catch (_) {
      return '';
    }
  }
}
