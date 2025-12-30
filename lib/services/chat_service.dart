import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'package:moomingle/services/supabase_service.dart';

class ChatService extends ChangeNotifier {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;

  ChatService() {
    fetchChats();
  }

  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('chats')
          .select()
          .order('last_message_time', ascending: false);

      // Safe type check to prevent crash on unexpected response format
      if (response is! List) {
        print('❌ Unexpected response format: ${response.runtimeType}');
        _loadMockData();
        return;
      }

      _chats = response.map((chat) {
        if (chat is! Map<String, dynamic>) return null;
        final chatId = chat['id'];
        if (chatId == null) return null; // Skip chats without ID
        
        return {
          'id': chatId.toString(),
          'name': chat['seller_name'] ?? 'Seller',
          'avatar': chat['avatar_url'] ?? AppConfig.defaultAvatarUrl,
          'lastMessage': chat['last_message'] ?? 'Start chatting!',
          'time': _formatTime(chat['last_message_time']?.toString()),
          'unread': chat['unread_count'] ?? 0,
          'listing': chat['listing_name'] ?? 'Listing',
          'matched': chat['is_matched'] ?? true,
          'messages': <Map<String, dynamic>>[],
        };
      }).whereType<Map<String, dynamic>>().toList();

      // Fetch messages for each chat
      for (var chat in _chats) {
        final chatId = chat['id'];
        if (chatId != null) {
          await _fetchMessagesForChat(chatId.toString());
        }
      }

      print('✅ Fetched ${_chats.length} chats from Supabase');
    } catch (e) {
      print('❌ Error fetching chats: $e');
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchMessagesForChat(String chatId) async {
    try {
      final response = await SupabaseService.client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      // Safe type check
      if (response is! List) {
        print('⚠️ Unexpected messages response format for chat $chatId');
        return;
      }

      final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
      if (chatIndex != -1 && chatIndex < _chats.length) {
        _chats[chatIndex]['messages'] = response.map((msg) {
          if (msg is! Map<String, dynamic>) return null;
          return {
            'text': msg['text']?.toString() ?? '',
            'isMe': msg['is_from_buyer'] == true,
            'time': _formatTime(msg['created_at']?.toString()),
          };
        }).whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      print('❌ Error fetching messages for chat $chatId: $e');
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return 'Now';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 1) return 'Now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}';
    } catch (e) {
      return 'Now';
    }
  }

  Map<String, dynamic>? getChatById(String id) {
    try {
      return _chats.firstWhere((c) => c['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    final chatIndex = _chats.indexWhere((c) => c['id'] == chatId);
    if (chatIndex == -1) return;

    // Optimistic update
    final chat = _chats[chatIndex];
    (chat['messages'] as List).add({
      'text': text,
      'isMe': true,
      'time': 'Now',
    });
    chat['lastMessage'] = text;
    chat['time'] = 'Now';
    notifyListeners();

    // Persist to Supabase
    try {
      await SupabaseService.client.from('messages').insert({
        'chat_id': chatId,
        'text': text,
        'is_from_buyer': true,
      });

      await SupabaseService.client.from('chats').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('id', chatId);

      print('✅ Message sent');
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }

  Future<String> startChat(String cowName, String sellerName) async {
    // Check if chat already exists for this listing
    final existingIndex = _chats.indexWhere((c) => c['listing'] == cowName);
    if (existingIndex != -1) {
      return _chats[existingIndex]['id'];
    }

    try {
      final response = await SupabaseService.client.from('chats').insert({
        'listing_name': cowName,
        'seller_name': sellerName,
        'buyer_name': 'You',
        'last_message': 'You matched with $cowName!',
        'is_matched': true,
      }).select().single();

      final newId = response['id'];

      // Add initial message
      await SupabaseService.client.from('messages').insert({
        'chat_id': newId,
        'text': 'You matched with $cowName! Say hello.',
        'is_from_buyer': true,
      });

      await fetchChats();
      return newId;
    } catch (e) {
      print('❌ Error starting chat: $e');
      // Fallback to local
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _chats.insert(0, {
        'id': newId,
        'name': sellerName,
        'avatar': AppConfig.defaultAvatarUrl,
        'lastMessage': 'You matched with $cowName!',
        'time': 'Now',
        'unread': 0,
        'listing': cowName,
        'matched': true,
        'messages': [
          {'text': 'You matched with $cowName! Say hello.', 'isMe': true, 'time': 'Now'},
        ],
      });
      notifyListeners();
      return newId;
    }
  }

  void _loadMockData() {
    // Only load mock data if feature flag is enabled
    if (!AppConfig.enableMockData) {
      _chats = [];
      return;
    }
    
    print('⚠️ Loading mock chat data (ENABLE_MOCK_DATA=true)');
    
    _chats = [
      {
        'id': 'mock-chat-1',
        'name': 'Rajesh Kumar',
        'avatar': AppConfig.defaultAvatarUrl,
        'lastMessage': 'Is this heifer still available?',
        'time': '9:41 AM',
        'unread': 2,
        'listing': 'Royal Murrah',
        'matched': true,
        'messages': [
          {'text': 'Hi, I saw your listing', 'isMe': false, 'time': '9:30 AM'},
          {'text': 'Is this heifer still available?', 'isMe': false, 'time': '9:41 AM'},
        ]
      },
    ];
  }
}
