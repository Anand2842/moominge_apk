import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/chat_service.dart';
import 'package:moomingle/screens/chat_detail_screen.dart';
import 'package:moomingle/widgets/safe_image.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _filterChats(List<Map<String, dynamic>> chats) {
    var filtered = chats;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((chat) {
        final name = (chat['name'] ?? '').toString().toLowerCase();
        final listing = (chat['listing'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || listing.contains(query);
      }).toList();
    }
    
    // Apply category filter
    switch (_selectedFilter) {
      case 'Matched':
        filtered = filtered.where((chat) => chat['matched'] == true).toList();
        break;
      case 'Unread':
        filtered = filtered.where((chat) => (chat['unread'] ?? 0) > 0).toList();
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text('Messages', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFF5D3A1A)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Matched'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread'),
              ],
            ),
          ),
          
          // Chat List
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                final filteredChats = _filterChats(chatService.chats);
                
                if (filteredChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'No chats found for "$_searchQuery"'
                              : 'No ${_selectedFilter.toLowerCase()} chats yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return _buildChatTile(context, chat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E2723) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF3E2723),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chat['id'],
            name: chat['name'],
            avatar: chat['avatar'],
            listingInfo: 'Interested in ${chat['listing']}',
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                SafeCircleAvatar(
                  radius: 28,
                  fallbackInitial: chat['name']?.toString().substring(0, 1) ?? 'U',
                ),
                if (chat['matched'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
                      if (chat['matched']) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3A15F),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('MATCHED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(chat['listing'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    chat['lastMessage'] ?? '',
                    style: TextStyle(
                      color: chat['unread'] > 0 ? const Color(0xFF3E2723) : Colors.grey,
                      fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD3A15F),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${chat['unread']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
