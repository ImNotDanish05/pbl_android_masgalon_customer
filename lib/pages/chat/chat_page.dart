import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/chat_dummy_data.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat/chat_filter_tabs.dart';
import '../../widgets/chat/chat_list_item.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentNavIndex = 3;
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatModel> get _filteredChats {
    List<ChatModel> chats = ChatDummyData.chatList;

    // Filter by tab
    if (_selectedFilter == 'Belum Dibaca') {
      chats = chats.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 'Kurir Aktif') {
      chats = chats.where((c) => c.isOnline).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      chats = chats
          .where(
            (c) =>
                c.kurirName.toLowerCase().contains(_searchQuery) ||
                c.lastMessage.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return chats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
          ),
        ],
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
            child: _filteredChats.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _filteredChats.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[100], indent: 76),
                    itemBuilder: (_, index) {
                      final chat = _filteredChats[index];
                      return ChatListItem(
                        chat: chat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(chat: chat),
                            ),
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
                Text(
                  'Tampilkan riwayat pesan lama',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lihat Arsip',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
