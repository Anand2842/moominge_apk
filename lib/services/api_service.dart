import 'package:flutter/material.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'package:moomingle/services/supabase_service.dart';
import '../config/app_config.dart';

class ApiService extends ChangeNotifier {
  List<CowListing> _listings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  List<CowListing> get listings => _listings;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  ApiService() {
    fetchListings();
  }

  /// Retry wrapper with exponential backoff
  Future<T> _withRetry<T>(Future<T> Function() fn, {int maxAttempts = 3}) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        return await fn();
      } catch (e) {
        if (i == maxAttempts - 1) rethrow;
        final delay = Duration(seconds: 1 << i); // 1s, 2s, 4s
        print('⚠️ Retry ${i + 1}/$maxAttempts after ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  /// Fetch listings with pagination (resets to page 1)
  Future<void> fetchListings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _listings = [];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _withRetry(() => SupabaseService.client
          .from('listings')
          .select()
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1));

      if (response is! List) {
        print('❌ Unexpected response format: ${response.runtimeType}');
        _error = 'Invalid response from server';
        _loadMockData();
        return;
      }

      _listings = response
          .map((json) {
            try {
              return CowListing.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ Skipping malformed listing: $e');
              return null;
            }
          })
          .whereType<CowListing>()
          .toList();
      
      _hasMore = response.length >= _pageSize;
      _currentPage = 1;
      print('✅ Fetched ${_listings.length} listings from Supabase');
    } catch (e) {
      print('❌ Error fetching listings: $e');
      _error = 'Failed to load listings';
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more listings (next page)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final start = _currentPage * _pageSize;
      final end = start + _pageSize - 1;

      final response = await _withRetry(() => SupabaseService.client
          .from('listings')
          .select()
          .order('created_at', ascending: false)
          .range(start, end));

      if (response is List && response.isNotEmpty) {
        final newListings = response
            .map((json) {
              try {
                return CowListing.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                return null;
              }
            })
            .whereType<CowListing>()
            .toList();

        _listings.addAll(newListings);
        _currentPage = nextPage;
        _hasMore = response.length >= _pageSize;
        print('✅ Loaded ${newListings.length} more listings (page $nextPage)');
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('❌ Error loading more: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> addListing(CowListing cow) async {
    try {
      await _withRetry(() => SupabaseService.client.from('listings').insert({
        'name': cow.name,
        'breed': cow.breed,
        'price': cow.price,
        'image_url': cow.imageUrl,
        'is_verified': cow.isVerified,
        'age': cow.age,
        'yield_amount': cow.yieldAmount,
        'location': cow.location,
        'seller_name': 'You',
      }));
      
      await fetchListings(refresh: true);
      print('✅ Listing added successfully');
    } catch (e) {
      print('❌ Error adding listing: $e');
      _listings.insert(0, cow);
      notifyListeners();
    }
  }


  /// Update an existing listing
  Future<bool> updateListing({
    required String id,
    String? name,
    String? breed,
    double? price,
    String? imageUrl,
    String? age,
    String? yieldAmount,
    String? location,
    String? animalType,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (breed != null) updates['breed'] = breed;
      if (price != null) updates['price'] = price;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (age != null) updates['age'] = age;
      if (yieldAmount != null) updates['yield_amount'] = yieldAmount;
      if (location != null) updates['location'] = location;
      if (animalType != null) updates['animal_type'] = animalType;
      if (status != null) updates['status'] = status;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _withRetry(() => SupabaseService.client
          .from('listings')
          .update(updates)
          .eq('id', id));

      await fetchListings(refresh: true);
      print('✅ Listing $id updated');
      return true;
    } catch (e) {
      print('❌ Error updating listing: $e');
      final index = _listings.indexWhere((l) => l.id == id);
      if (index != -1) {
        final old = _listings[index];
        _listings[index] = CowListing(
          id: old.id,
          name: name ?? old.name,
          breed: breed ?? old.breed,
          price: price ?? old.price,
          imageUrl: imageUrl ?? old.imageUrl,
          isVerified: old.isVerified,
          age: age ?? old.age,
          yieldAmount: yieldAmount ?? old.yieldAmount,
          location: location ?? old.location,
          sellerName: old.sellerName,
          animalType: animalType ?? old.animalType,
        );
        notifyListeners();
      }
      return true;
    }
  }

  /// Delete a listing
  Future<bool> deleteListing(String id) async {
    try {
      await _withRetry(() => SupabaseService.client
          .from('listings')
          .delete()
          .eq('id', id));

      _listings.removeWhere((l) => l.id == id);
      notifyListeners();
      print('✅ Listing $id deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting listing: $e');
      _listings.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    }
  }

  /// Pause/unpause a listing
  Future<bool> toggleListingStatus(String id, String newStatus) async {
    return updateListing(id: id, status: newStatus);
  }

  void _loadMockData() {
    // Only load mock data if feature flag is enabled
    if (!AppConfig.enableMockData || _listings.isNotEmpty) return;
    
    print('⚠️ Loading mock data (ENABLE_MOCK_DATA=true)');
    
    _listings = [
      CowListing(
        id: 'mock-1',
        name: 'Royal Murrah',
        breed: 'Murrah',
        price: 85000,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Murrah_buffalo.JPG',
        isVerified: true,
        age: '4 Years',
        yieldAmount: '18L / Day',
        location: 'Rohtak, Haryana',
      ),
      CowListing(
        id: 'mock-2',
        name: 'Gir Queen',
        breed: 'Gir',
        price: 120000,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Gir_cattle.jpg/800px-Gir_cattle.jpg',
        isVerified: true,
        age: '4 Years',
        yieldAmount: '16L / Day',
        location: 'Junagadh, Gujarat',
      ),
    ];
  }
}
