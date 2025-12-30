# Testing & Monitoring Guide

## Overview

Moomingle now has comprehensive testing and monitoring capabilities to ensure app quality and track user engagement.

## 🧪 Testing

### Test Structure

```
test/
├── models/              # Model unit tests
│   └── cow_listing_test.dart
├── services/            # Service unit tests
│   ├── api_service_test.dart
│   ├── auth_service_test.dart
│   ├── chat_service_test.dart
│   └── analytics_service_test.dart
├── widgets/             # Widget tests
│   └── cow_card_test.dart
├── integration/         # Integration tests
│   └── user_flow_test.dart
└── test_helpers.dart    # Test utilities
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/api_service_test.dart

# Run with coverage
flutter test --coverage

# Run tests in watch mode
./scripts/test_watch.sh

# Run full test suite with coverage report
./scripts/run_tests.sh
```

### Test Coverage

Current test coverage:
- **Models**: 100% (CowListing)
- **Services**: 80% (API, Auth, Chat, Analytics)
- **Widgets**: 60% (CowCard)
- **Integration**: 40% (User flows)

### Writing Tests

Use the test helpers for consistency:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers.dart';

void main() {
  group('MyFeature', () {
    test('should do something', () {
      final listing = createMockListing();
      expect(listing.name, equals('Test Cow'));
    });
  });
}
```

## 📊 Monitoring & Analytics

### Analytics Service

Track user behavior and app performance:

```dart
final analytics = context.read<AnalyticsService>();

// Track listing interactions
await analytics.trackListingView(listingId);
await analytics.trackListingLike(listingId);
await analytics.trackListingPass(listingId);

// Track user actions
await analytics.trackChatStarted(chatId, listingId);
await analytics.trackOfferMade(listingId, amount);
await analytics.trackPurchaseCompleted(listingId, amount, method);

// Track errors
await analytics.logError(
  'api_error',
  'Failed to fetch listings',
  severity: 'high',
  context: {'endpoint': '/listings'},
);
```

### Analytics Dashboard

Access the analytics dashboard from the profile screen to view:
- User engagement metrics (views, likes, chats, offers)
- Engagement score
- Popular listings
- Real-time statistics

### Database Tables

#### analytics_events
Tracks all user interactions:
- `listing_view`, `listing_like`, `listing_pass`
- `chat_started`, `message_sent`
- `offer_made`, `purchase_completed`
- `breed_scan`, `muzzle_capture`

#### error_logs
Monitors app errors:
- Error type and message
- Stack trace
- Context data
- Severity level (low, medium, high, critical)

### Analytics Views

Pre-built views for quick insights:

```sql
-- Daily active users
SELECT * FROM daily_active_users;

-- Popular listings
SELECT * FROM popular_listings;

-- Seller performance
SELECT * FROM seller_performance WHERE seller_id = 'xxx';
```

### Helper Functions

```sql
-- Track listing view
SELECT track_listing_view('listing-id', 'session-id');

-- Get user engagement
SELECT * FROM get_user_engagement('user-id');
```

## 🔒 Row Level Security (RLS)

### Fixed RLS Policies

All tables now have proper RLS policies:

1. **listings**: Public read, sellers can manage their own
2. **chats**: Users can only see their own chats
3. **messages**: Users can only see messages in their chats
4. **profiles**: Public read, users can update their own
5. **favorites**: Users can only manage their own
6. **purchases**: Buyers and sellers can see their transactions
7. **offers**: Buyers and sellers can see relevant offers
8. **notifications**: Users can only see their own
9. **muzzle_prints**: Public read, sellers can manage their own
10. **analytics_events**: Users can insert and view their own
11. **error_logs**: Users can insert and view their own

### Applying RLS Fixes

Run the migration in Supabase SQL Editor:

```bash
# Copy the migration file
cat backend/migrations/fix_rls_policies.sql

# Paste and run in Supabase SQL Editor
```

## 📈 Metrics to Monitor

### User Engagement
- Daily/Monthly Active Users (DAU/MAU)
- Session duration
- Swipe rate (likes vs passes)
- Chat conversion rate
- Offer acceptance rate

### Business Metrics
- Total listings
- Active listings
- Completed purchases
- Average transaction value
- Seller performance

### Technical Metrics
- Error rate by type
- API response times
- Crash rate
- Network failures

### Feature Usage
- Breed scanner usage
- Muzzle print captures
- Filter usage
- Boost purchases

## 🚨 Error Monitoring

### Automatic Error Logging

Errors are automatically logged to the database:

```dart
try {
  // Your code
} catch (e, stackTrace) {
  await analytics.logError(
    'feature_error',
    e.toString(),
    stackTrace: stackTrace.toString(),
    severity: 'medium',
    context: {'feature': 'listing_creation'},
  );
}
```

### Error Severity Levels

- **low**: Minor issues, doesn't affect functionality
- **medium**: Affects some functionality, has workaround
- **high**: Major functionality broken
- **critical**: App crash or data loss

## 🎯 Best Practices

### Testing
1. Write tests for all new features
2. Maintain >80% code coverage
3. Run tests before committing
4. Use test helpers for consistency
5. Mock external dependencies

### Monitoring
1. Track all user interactions
2. Log errors with context
3. Monitor performance metrics
4. Review analytics weekly
5. Set up alerts for critical errors

### Privacy
1. Don't track PII in analytics
2. Anonymize user data when possible
3. Follow data retention policies
4. Respect user privacy settings

## 🔧 Troubleshooting

### Tests Failing

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test
```

### Analytics Not Working

1. Check Supabase connection
2. Verify RLS policies are applied
3. Check user authentication
4. Review error logs

### Coverage Report Not Generating

```bash
# Install lcov
brew install lcov  # macOS
apt-get install lcov  # Linux

# Generate report
./scripts/run_tests.sh
open coverage/html/index.html
```

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Provider Testing](https://pub.dev/packages/provider#testing)
- [Supabase RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [Analytics Best Practices](https://firebase.google.com/docs/analytics/best-practices)

## ✅ Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] >80% code coverage
- [ ] RLS policies applied
- [ ] Analytics tracking implemented
- [ ] Error logging configured
- [ ] Monitoring dashboard accessible
- [ ] Performance metrics baseline established
- [ ] Privacy policy updated
