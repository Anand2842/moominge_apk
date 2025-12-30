import 'package:flutter/material.dart';
import 'package:moomingle/services/supabase_service.dart';
import 'package:moomingle/models/cow_listing.dart';
import '../config/app_config.dart';

/// Notification model
class SellerNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool read;
  final String type; // match, price_alert, expiring, message

  SellerNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.type = 'general',
  });

  factory SellerNotification.fromJson(Map<String, dynamic> json) {
    return SellerNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: _formatTime(json['created_at']),
      read: json['read'] == true,
      type: json['type'] ?? 'general',
    );
  }

  static String _formatTime(String? timestamp) {
    if (timestamp == null) return 'Now';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 1) return 'Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}';
    } catch (e) {
      return 'Now';
    }
  }
}

/// Seller listing with stats
class SellerListing {
  final String id;
  final String breed;
  final double price;
  final String imageUrl;
  final String status; // active, pending, sold, paused
  final int views;
  final int matches;
  final int daysAgo;
  final DateTime? createdAt;

  SellerListing({
    required this.id,
    required this.breed,
    required this.price,
    required this.imageUrl,
    required this.status,
    this.views = 0,
    this.matches = 0,
    this.daysAgo = 0,
    this.createdAt,
  });

  factory SellerListing.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null 
        ? DateTime.tryParse(json['created_at']) 
        : null;
    final daysAgo = createdAt != null 
        ? DateTime.now().difference(createdAt).inDays 
        : 0;

    return SellerListing(
      id: json['id']?.toString() ?? '',
      breed: json['breed'] ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 'active',
      views: json['views'] ?? 0,
      matches: json['matches'] ?? 0,
      daysAgo: daysAgo,
      createdAt: createdAt,
    );
  }
}

/// Service for seller-specific statistics and data
class SellerStatsService extends ChangeNotifier {
  List<SellerListing> _listings = [];
  List<SellerNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Aggregate stats
  int _totalViews = 0;
  int _totalMatches = 0;
  int _interestedBuyers = 0;
  int _newBuyersToday = 0;

  List<SellerListing> get listings => _listings;
  List<SellerNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalViews => _totalViews;
  int get totalMatches => _totalMatches;
  int get interestedBuyers => _interestedBuyers;
  int get newBuyersToday => _newBuyersToday;
  int get activeListingsCount => _listings.where((l) => l.status == 'active').length;
  int get unreadNotifications => _notifications.where((n) => !n.read).length;

  /// Fetch seller's listings with stats
  Future<void> fetchSellerListings(String? sellerId) async {
    if (sellerId == null) {
      _loadDemoData();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('listings')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      // Safe type check to prevent crash on unexpected response format
      if (response is! List) {
        print('❌ Unexpected response format: ${response.runtimeType}');
        _error = 'Invalid response from server';
        _loadDemoData();
        return;
      }

      _listings = response
          .map((json) {
            try {
              if (json is! Map<String, dynamic>) return null;
              return SellerListing.fromJson(json);
            } catch (e) {
              print('⚠️ Skipping malformed listing: $e');
              return null;
            }
          })
          .whereType<SellerListing>()
          .toList();

      // Calculate aggregate stats
      _totalViews = _listings.fold(0, (sum, l) => sum + l.views);
      _totalMatches = _listings.fold(0, (sum, l) => sum + l.matches);

      // Fetch interested buyers (chats for this seller's listings)
      await _fetchInterestedBuyers(sellerId);

      print('✅ Fetched ${_listings.length} seller listings');
    } catch (e) {
      print('❌ Error fetching seller listings: $e');
      _error = 'Failed to load listings';
      _loadDemoData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchInterestedBuyers(String sellerId) async {
    try {
      final response = await SupabaseService.client
          .from('chats')
          .select('id, created_at')
          .eq('seller_id', sellerId);

      // Safe type check
      if (response is! List) {
        print('⚠️ Unexpected chats response format');
        _interestedBuyers = 0;
        _newBuyersToday = 0;
        return;
      }

      _interestedBuyers = response.length;

      // Count new buyers today
      final today = DateTime.now();
      _newBuyersToday = response.where((chat) {
        if (chat is! Map<String, dynamic>) return false;
        final createdAtStr = chat['created_at']?.toString();
        if (createdAtStr == null) return false;
        final createdAt = DateTime.tryParse(createdAtStr);
        return createdAt != null &&
            createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).length;
    } catch (e) {
      print('⚠️ Error fetching interested buyers: $e');
      _interestedBuyers = 0;
      _newBuyersToday = 0;
    }
  }

  /// Fetch seller notifications
  Future<void> fetchNotifications(String? sellerId) async {
    if (sellerId == null) {
      _loadDemoNotifications();
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', sellerId)
          .order('created_at', ascending: false)
          .limit(20);

      // Safe type check
      if (response is! List) {
        print('⚠️ Unexpected notifications response format');
        _loadDemoNotifications();
        return;
      }

      _notifications = response
          .map((json) {
            try {
              if (json is! Map<String, dynamic>) return null;
              return SellerNotification.fromJson(json);
            } catch (e) {
              print('⚠️ Skipping malformed notification: $e');
              return null;
            }
          })
          .whereType<SellerNotification>()
          .toList();

      if (_notifications.isEmpty) {
        _loadDemoNotifications();
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Error fetching notifications: $e');
      _loadDemoNotifications();
    }
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = SellerNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        time: _notifications[index].time,
        read: true,
        type: _notifications[index].type,
      );
      notifyListeners();

      try {
        await SupabaseService.client
            .from('notifications')
            .update({'read': true})
            .eq('id', notificationId);
      } catch (e) {
        print('⚠️ Error marking notification read: $e');
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    _notifications = _notifications.map((n) => SellerNotification(
      id: n.id,
      title: n.title,
      body: n.body,
      time: n.time,
      read: true,
      type: n.type,
    )).toList();
    notifyListeners();

    // Update in database would go here
  }

  void _loadDemoData() {
    // Only load demo data if feature flag is enabled
    if (!AppConfig.enableMockData) {
      _listings = [];
      _totalViews = 0;
      _totalMatches = 0;
      _interestedBuyers = 0;
      _newBuyersToday = 0;
      return;
    }
    
    print('⚠️ Loading demo seller stats (ENABLE_MOCK_DATA=true)');
    
    _listings = [];
    _totalViews = 0;
    _totalMatches = 0;
    _interestedBuyers = 0;
    _newBuyersToday = 0;
  }

  void _loadDemoNotifications() {
    // Only show if no real notifications and mock data enabled
    if (_notifications.isEmpty && AppConfig.enableMockData) {
      _notifications = [
        SellerNotification(
          id: 'demo1',
          title: 'Welcome to Moomingle!',
          body: 'Start by listing your first cattle',
          time: 'Now',
          read: false,
          type: 'general',
        ),
      ];
    }
  }

  /// Get listing by ID
  SellerListing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get listings by status
  List<SellerListing> getListingsByStatus(String status) {
    if (status == 'All') return _listings;
    return _listings.where((l) => l.status.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Delete a listing from database and local state
  Future<bool> deleteListing(String listingId) async {
    try {
      await SupabaseService.client
          .from('listings')
          .delete()
          .eq('id', listingId);

      // Remove from local state
      _listings.removeWhere((l) => l.id == listingId);
      
      // Recalculate stats
      _totalViews = _listings.fold(0, (sum, l) => sum + l.views);
      _totalMatches = _listings.fold(0, (sum, l) => sum + l.matches);
      
      notifyListeners();
      print('✅ Listing $listingId deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting listing: $e');
      // Still remove from local state for demo mode
      _listings.removeWhere((l) => l.id == listingId);
      notifyListeners();
      return true; // Return true for demo mode
    }
  }

  /// Pause/unpause a listing
  Future<bool> toggleListingStatus(String listingId, String newStatus) async {
    try {
      await SupabaseService.client
          .from('listings')
          .update({'status': newStatus})
          .eq('id', listingId);

      // Update local state
      final index = _listings.indexWhere((l) => l.id == listingId);
      if (index != -1) {
        final old = _listings[index];
        _listings[index] = SellerListing(
          id: old.id,
          breed: old.breed,
          price: old.price,
          imageUrl: old.imageUrl,
          status: newStatus,
          views: old.views,
          matches: old.matches,
          daysAgo: old.daysAgo,
          createdAt: old.createdAt,
        );
      }
      
      notifyListeners();
      print('✅ Listing $listingId status changed to $newStatus');
      return true;
    } catch (e) {
      print('❌ Error updating listing status: $e');
      // Still update local state for demo mode
      final index = _listings.indexWhere((l) => l.id == listingId);
      if (index != -1) {
        final old = _listings[index];
        _listings[index] = SellerListing(
          id: old.id,
          breed: old.breed,
          price: old.price,
          imageUrl: old.imageUrl,
          status: newStatus,
          views: old.views,
          matches: old.matches,
          daysAgo: old.daysAgo,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    }
  }

  void clear() {
    _listings = [];
    _notifications = [];
    _totalViews = 0;
    _totalMatches = 0;
    _interestedBuyers = 0;
    _newBuyersToday = 0;
    notifyListeners();
  }
}
