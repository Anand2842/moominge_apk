/// Application constants and placeholder URLs
class AppConstants {
  // Placeholder Images (for demo/development)
  static const String cattlePlaceholder = 
      'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=800';
  
  static const String buffaloPlaceholder = 
      'https://images.unsplash.com/photo-1546445317-29f4545e9d53?w=800';
  
  static const String highlanderCowPlaceholder = 
      'https://images.unsplash.com/photo-1541604193435-22287d32c212?w=800';
  
  // Default avatar for users without profile pictures
  static const String defaultAvatarUrl = 
      'https://randomuser.me/api/portraits/men/1.jpg';
  
  // Breed-specific placeholder images (for breed selection)
  static const Map<String, String> breedPlaceholders = {
    'Murrah': 'https://images.unsplash.com/photo-1546445317-29f4545e9d53?w=400',
    'Gir': 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=400',
    'Sahiwal': 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
    // Add more as needed
  };
  
  // UI Constants
  static const double cardBorderRadius = 32.0;
  static const double buttonBorderRadius = 20.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Swipe Thresholds
  static const double swipeThreshold = 100.0;
  static const double swipeVelocityThreshold = 300.0;
  
  // Listing Limits
  static const int maxImagesPerListing = 10;
  static const int minImagesPerListing = 1;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  
  // Price Limits (in INR)
  static const double minPrice = 1000.0;
  static const double maxPrice = 10000000.0;
  
  // Cache Settings
  static const int maxCachedImages = 100;
  static const Duration imageCacheDuration = Duration(days: 7);
}
