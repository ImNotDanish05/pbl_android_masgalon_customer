import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/chat_dummy_data.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat/chat_filter_tabs.dart';
import '../../widgets/chat/chat_list_item.dart';
import '../../widgets/shared/custom_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import 'chat_detail_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  int _currentNavIndex = 3;
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _chatService = ChatService();
  late Future<List<ChatModel>> _chatFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadData();
  }

  void _loadData() {
    setState(() {
      _chatFuture = _chatService.getDaftarChat();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatModel> _getFilteredChats(List<ChatModel> allChats) {
    List<ChatModel> filtered = allChats;

    if (_selectedFilter == 'Belum Dibaca') {
      filtered = filtered.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 'Kurir Aktif') {
      filtered = filtered.where((c) => c.isOnline).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.kurirName.toLowerCase().contains(_searchQuery) ||
                c.lastMessage.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authCustomerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chat',
        showLogo: true,
        showNotifications: true,
        showProfileAvatar: true,
        profileImageUrl: customer?.avatarUrl,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari pesan...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Filter tabs
          ChatFilterTabs(
            selected: _selectedFilter,
            onChanged: (val) => setState(() => _selectedFilter = val),
          ),
          const SizedBox(height: 8),

          // Chat list
          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: _chatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && !snapshot.hasData) {
                  return const Center(child: Text('Gagal memuat chat'));
                }

                final chats = snapshot.data ?? [];
                final displayChats = _getFilteredChats(chats);

                if (displayChats.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  itemCount: displayChats.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[100], indent: 76),
                  itemBuilder: (_, index) {
                    final chat = displayChats[index];
                    return ChatListItem(
                      chat: chat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailPage(chat: chat),
                          ),
                        ).then(
                          (_) {
                            if (mounted) _loadData();
                          },
                        ); // Refresh halaman saat kembali dari chat
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Arsip section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF2FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.darkBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (i) {
          if (i == 0) {
            context.go('/home');
          } else if (i == 1) {
            context.go('/orders');
          } else if (i == 2) {
            context.go('/profile');
          } else if (i == 3) {
            context.go('/chat');
          }
          setState(() => _currentNavIndex = i);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Tidak ada chat ditemukan',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}