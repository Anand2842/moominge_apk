import 'package:flutter/material.dart';
import 'package:moomingle/services/supabase_service.dart';
import '../config/app_config.dart';

/// User profile model
class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? location;
  final String role; // buyer, seller, both
  final bool isVerified;
  final String? tier; // bronze, silver, gold
  final DateTime? createdAt;
  
  // Stats
  final int activeBids;
  final int purchased;
  final int favorites;
  final int totalListings;
  final double rating;

  UserProfile({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.avatarUrl,
    this.location,
    this.role = 'both',
    this.isVerified = false,
    this.tier,
    this.createdAt,
    this.activeBids = 0,
    this.purchased = 0,
    this.favorites = 0,
    this.totalListings = 0,
    this.rating = 0.0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'User',
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      location: json['location'],
      role: json['role'] ?? 'both',
      isVerified: json['is_verified'] == true,
      tier: json['tier'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      activeBids: json['active_bids'] ?? 0,
      purchased: json['purchased'] ?? 0,
      favorites: json['favorites'] ?? 0,
      totalListings: json['total_listings'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'avatar_url': avatarUrl,
    'location': location,
    'role': role,
    'is_verified': isVerified,
    'tier': tier,
  };

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? location,
    String? role,
    bool? isVerified,
    String? tier,
    int? activeBids,
    int? purchased,
    int? favorites,
    int? totalListings,
    double? rating,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      tier: tier ?? this.tier,
      createdAt: createdAt,
      activeBids: activeBids ?? this.activeBids,
      purchased: purchased ?? this.purchased,
      favorites: favorites ?? this.favorites,
      totalListings: totalListings ?? this.totalListings,
      rating: rating ?? this.rating,
    );
  }
}

/// Service for managing user profile data
class UserProfileService extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Fetch current user's profile
  Future<void> fetchProfile() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      _profile = _getDemoProfile();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _profile = UserProfile.fromJson(response);
        // Fetch additional stats
        await _fetchUserStats(user.id);
      } else {
        // Create default profile for new user
        _profile = UserProfile(
          id: user.id,
          name: user.email?.split('@').first ?? 'User',
          email: user.email,
          phone: user.phone,
        );
        await _createProfile(_profile!);
      }
      print('✅ Profile loaded: ${_profile?.name}');
    } catch (e) {
      print('❌ Error fetching profile: $e');
      _error = 'Failed to load profile';
      _profile = _getDemoProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch user statistics
  Future<void> _fetchUserStats(String userId) async {
    try {
      // Count user's listings
      final listingsResponse = await SupabaseService.client
          .from('listings')
          .select('id')
          .eq('seller_id', userId);
      
      // Count favorites
      final favoritesResponse = await SupabaseService.client
          .from('favorites')
          .select('id')
          .eq('user_id', userId);

      // Count purchases (matched/completed chats)
      final purchasesResponse = await SupabaseService.client
          .from('purchases')
          .select('id')
          .eq('buyer_id', userId);

      // Count active bids/offers
      final bidsResponse = await SupabaseService.client
          .from('offers')
          .select('id')
          .eq('buyer_id', userId)
          .eq('status', 'pending');

      _profile = _profile?.copyWith(
        totalListings: (listingsResponse as List).length,
        favorites: (favoritesResponse as List).length,
        purchased: (purchasesResponse as List).length,
        activeBids: (bidsResponse as List).length,
      );
    } catch (e) {
      print('⚠️ Could not fetch user stats: $e');
      // Stats tables might not exist yet, use defaults
    }
  }

  /// Create a new profile
  Future<void> _createProfile(UserProfile profile) async {
    try {
      await SupabaseService.client.from('profiles').insert(profile.toJson());
      print('✅ Profile created');
    } catch (e) {
      print('⚠️ Could not create profile: $e');
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? avatarUrl,
    String? role,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (role != null) updates['role'] = role;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await SupabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', _profile!.id);

      _profile = _profile!.copyWith(
        name: name,
        phone: phone,
        location: location,
        avatarUrl: avatarUrl,
        role: role,
      );

      print('✅ Profile updated');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add to favorites
  Future<void> addFavorite(String listingId) async {
    if (_profile == null) return;
    
    try {
      await SupabaseService.client.from('favorites').insert({
        'user_id': _profile!.id,
        'listing_id': listingId,
      });
      _profile = _profile!.copyWith(favorites: _profile!.favorites + 1);
      notifyListeners();
    } catch (e) {
      print('⚠️ Could not add favorite: $e');
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String listingId) async {
    if (_profile == null) return;
    
    try {
      await SupabaseService.client
          .from('favorites')
          .delete()
          .eq('user_id', _profile!.id)
          .eq('listing_id', listingId);
      _profile = _profile!.copyWith(
        favorites: (_profile!.favorites - 1).clamp(0, 999),
      );
      notifyListeners();
    } catch (e) {
      print('⚠️ Could not remove favorite: $e');
    }
  }

  /// Clear profile (on logout)
  void clearProfile() {
    _profile = null;
    _error = null;
    notifyListeners();
  }

  /// Set demo profile for demo mode
  void setDemoProfile() {
    _profile = _getDemoProfile();
    notifyListeners();
  }

  UserProfile _getDemoProfile() {
    // Only return demo profile if mock data is enabled
    if (!AppConfig.enableMockData) {
      throw Exception('No user profile available and mock data disabled');
    }
    
    print('⚠️ Using demo profile (ENABLE_MOCK_DATA=true)');
    
    return UserProfile(
      id: 'demo-user',
      name: 'Demo User',
      email: 'stufi339@gmail.com',
      location: 'Delhi, India',
      role: 'both',
      isVerified: false,
      tier: 'bronze',
      activeBids: 0,
      purchased: 0,
      favorites: 0,
      totalListings: 0,
      rating: 0.0,
    );
  }
}
