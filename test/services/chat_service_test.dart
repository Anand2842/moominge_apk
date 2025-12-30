import 'package:flutter_test/flutter_test.dart';
import 'package:moomingle/services/chat_service.dart';

void main() {
  group('ChatService', () {
    late ChatService chatService;

    setUp(() {
      chatService = ChatService();
    });

    test('should initialize with empty chats', () {
      expect(chatService.chats, isEmpty);
      expect(chatService.isLoading, isFalse);
    });

    test('should fetch chats', () async {
      await chatService.fetchChats();
      expect(chatService.isLoading, isFalse);
    });

    test('should fetch messages for chat', () async {
      final messages = await chatService.fetchMessages('test-chat-id');
      expect(messages, isNotNull);
    });

    test('should send message', () async {
      await chatService.sendMessage('test-chat-id', 'Hello!');
      // Should not throw error
    });

    test('should create new chat', () async {
      await chatService.createChat(
        listingId: 'listing-id',
        sellerId: 'seller-id',
        cowName: 'Test Cow',
        sellerName: 'Test Seller',
      );
      // Should not throw error
    });

    test('should get unread count', () {
      final count = chatService.getUnreadCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
