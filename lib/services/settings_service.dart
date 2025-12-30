import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moomingle/services/supabase_service.dart';

/// Saved search model
class SavedSearch {
  final String id;
  final String name;
  final List<String> breeds;
  final double minPrice;
  final double maxPrice;
  final double maxDistance;
  final bool verifiedOnly;
  final DateTime createdAt;

  SavedSearch({
    required this.id,
    required this.name,
    required this.breeds,
    required this.minPrice,
    required this.maxPrice,
    required this.maxDistance,
    required this.verifiedOnly,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'breeds': breeds,
    'min_price': minPrice,
    'max_price': maxPrice,
    'max_distance': maxDistance,
    'verified_only': verifiedOnly,
    'created_at': createdAt.toIso8601String(),
  };

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Saved Search',
      breeds: List<String>.from(json['breeds'] ?? []),
      minPrice: (json['min_price'] ?? 50000).toDouble(),
      maxPrice: (json['max_price'] ?? 200000).toDouble(),
      maxDistance: (json['max_distance'] ?? 100).toDouble(),
      verifiedOnly: json['verified_only'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}

/// Service for managing user settings and preferences
class SettingsService extends ChangeNotifier {
  // Notification settings
  bool _matchAlerts = true;
  bool _messageAlerts = true;
  bool _priceAlerts = false;
  bool _marketingAlerts = false;
  
  // Seller settings
  bool _autoRelist = false;
  bool _chatAlerts = true;
  bool _marketAnalytics = false;
  
  // Dashboard customization
  Map<String, bool> _dashboardItems = {
    'Quick Actions': true,
    'Recent Activity': true,
    'Performance Stats': false,
    'Market Trends': false,
  };
  
  // Saved searches
  List<SavedSearch> _savedSearches = [];
  
  bool _isLoading = false;

  // Getters
  bool get matchAlerts => _matchAlerts;
  bool get messageAlerts => _messageAlerts;
  bool get priceAlerts => _priceAlerts;
  bool get marketingAlerts => _marketingAlerts;
  bool get autoRelist => _autoRelist;
  bool get chatAlerts => _chatAlerts;
  bool get marketAnalytics => _marketAnalytics;
  Map<String, bool> get dashboardItems => Map.from(_dashboardItems);
  List<SavedSearch> get savedSearches => _savedSearches;
  bool get isLoading => _isLoading;

  SettingsService() {
    _loadSettings();
  }

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      _matchAlerts = prefs.getBool('match_alerts') ?? true;
      _messageAlerts = prefs.getBool('message_alerts') ?? true;
      _priceAlerts = prefs.getBool('price_alerts') ?? false;
      _marketingAlerts = prefs.getBool('marketing_alerts') ?? false;
      _autoRelist = prefs.getBool('auto_relist') ?? false;
      _chatAlerts = prefs.getBool('chat_alerts') ?? true;
      _marketAnalytics = prefs.getBool('market_analytics') ?? false;
      
      // Load dashboard settings
      final dashQuickActions = prefs.getBool('dash_quick_actions') ?? true;
      final dashRecentActivity = prefs.getBool('dash_recent_activity') ?? true;
      final dashPerformanceStats = prefs.getBool('dash_performance_stats') ?? false;
      final dashMarketTrends = prefs.getBool('dash_market_trends') ?? false;
      _dashboardItems = {
        'Quick Actions': dashQuickActions,
        'Recent Activity': dashRecentActivity,
        'Performance Stats': dashPerformanceStats,
        'Market Trends': dashMarketTrends,
      };
      
      // Load saved searches
      final searchesJson = prefs.getStringList('saved_searches') ?? [];
      _savedSearches = searchesJson.map((json) {
        try {
          final map = Map<String, dynamic>.from(
            Uri.splitQueryString(json).map((k, v) => MapEntry(k, _parseValue(v)))
          );
          return SavedSearch.fromJson(map);
        } catch (e) {
          return null;
        }
      }).whereType<SavedSearch>().toList();

      print('✅ Settings loaded');
    } catch (e) {
      print('⚠️ Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  dynamic _parseValue(String value) {
    if (value == 'true') return true;
    if (value == 'false') return false;
    final num? number = num.tryParse(value);
    if (number != null) return number;
    return value;
  }

  /// Update notification settings
  Future<void> setMatchAlerts(bool value) async {
    _matchAlerts = value;
    notifyListeners();
    await _saveToPrefs('match_alerts', value);
  }

  Future<void> setMessageAlerts(bool value) async {
    _messageAlerts = value;
    notifyListeners();
    await _saveToPrefs('message_alerts', value);
  }

  Future<void> setPriceAlerts(bool value) async {
    _priceAlerts = value;
    notifyListeners();
    await _saveToPrefs('price_alerts', value);
  }

  Future<void> setMarketingAlerts(bool value) async {
    _marketingAlerts = value;
    notifyListeners();
    await _saveToPrefs('marketing_alerts', value);
  }

  /// Update seller settings
  Future<void> setAutoRelist(bool value) async {
    _autoRelist = value;
    notifyListeners();
    await _saveToPrefs('auto_relist', value);
  }

  Future<void> setChatAlerts(bool value) async {
    _chatAlerts = value;
    notifyListeners();
    await _saveToPrefs('chat_alerts', value);
  }

  Future<void> setMarketAnalytics(bool value) async {
    _marketAnalytics = value;
    notifyListeners();
    await _saveToPrefs('market_analytics', value);
  }

  /// Update dashboard customization
  Future<void> updateDashboardItems(Map<String, bool> items) async {
    _dashboardItems = Map.from(items);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dash_quick_actions', items['Quick Actions'] ?? true);
      await prefs.setBool('dash_recent_activity', items['Recent Activity'] ?? true);
      await prefs.setBool('dash_performance_stats', items['Performance Stats'] ?? false);
      await prefs.setBool('dash_market_trends', items['Market Trends'] ?? false);
      print('✅ Dashboard settings saved');
    } catch (e) {
      print('⚠️ Error saving dashboard settings: $e');
    }
  }

  Future<void> _saveToPrefs(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('⚠️ Error saving setting: $e');
    }
  }

  /// Add a saved search
  Future<void> addSavedSearch(SavedSearch search) async {
    _savedSearches.add(search);
    notifyListeners();
    await _persistSavedSearches();
  }

  /// Remove a saved search
  Future<void> removeSavedSearch(String searchId) async {
    _savedSearches.removeWhere((s) => s.id == searchId);
    notifyListeners();
    await _persistSavedSearches();
  }

  Future<void> _persistSavedSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchesJson = _savedSearches.map((s) {
        final json = s.toJson();
        return json.entries.map((e) => '${e.key}=${e.value}').join('&');
      }).toList();
      await prefs.setStringList('saved_searches', searchesJson);
    } catch (e) {
      print('⚠️ Error saving searches: $e');
    }
  }

  /// Clear all settings (on logout)
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset to defaults
      _matchAlerts = true;
      _messageAlerts = true;
      _priceAlerts = false;
      _marketingAlerts = false;
      _autoRelist = false;
      _chatAlerts = true;
      _marketAnalytics = false;
      _savedSearches = [];
      
      notifyListeners();
    } catch (e) {
      print('⚠️ Error clearing settings: $e');
    }
  }
}
