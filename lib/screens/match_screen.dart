import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/chat_service.dart';
import 'package:moomingle/services/user_profile_service.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'package:moomingle/screens/chat_detail_screen.dart';
import 'package:moomingle/widgets/safe_image.dart';

class MatchScreen extends StatelessWidget {
  final CowListing cow;

  const MatchScreen({super.key, required this.cow});

  Future<void> _callSeller(BuildContext context) async {
    // In production, phone would come from seller profile via Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seller phone not available. Use chat instead.'),
        backgroundColor: Color(0xFFD3A15F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileService>().profile;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            const Text(
              "It's a Match!",
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You and this livestock are a great fit.',
              style: TextStyle(
                color: Color(0xFF8B5A2B),
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Overlapping Avatars
            SizedBox(
              height: 200,
              width: 300,
              child: Stack(
                 alignment: Alignment.center,
                 children: [
                   // User Avatar (Left)
                   Positioned(
                     left: 20,
                     child: Container(
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(color: const Color(0xFFF5E0C3), width: 8),
                       ),
                       child: SafeCircleAvatar(
                         radius: 70,
                         imageUrl: userProfile?.avatarUrl,
                         fallbackInitial: userProfile?.name.isNotEmpty == true ? userProfile!.name[0].toUpperCase() : 'U',
                       ),
                     ),
                   ),
                   // Cow Avatar (Right)
                   Positioned(
                     right: 20,
                     child: Container(
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(color: const Color(0xFFF5E0C3), width: 8),
                       ),
                       child: CircleAvatar(
                         radius: 70,
                         backgroundImage: cow.imageUrl.isNotEmpty 
                             ? NetworkImage(cow.imageUrl) 
                             : null,
                         backgroundColor: const Color(0xFFD3A15F),
                         child: cow.imageUrl.isEmpty 
                             ? const Icon(Icons.pets, size: 40, color: Colors.white)
                             : null,
                       ),
                     ),
                   ),
                   // Heart Icon in Center
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                       ]
                     ),
                     child: const Icon(Icons.favorite, color: Color(0xFF4CAF50), size: 30),
                   )
                 ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Cow Tag Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF6EE),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (cow.isVerified)
                     const Icon(Icons.verified, color: Color(0xFF4CAF50)),
                   if (cow.isVerified)
                     const SizedBox(width: 8),
                   Text(
                     '${cow.breed} #${cow.id}',
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723)),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Text block
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Would you like to start a conversation with the seller?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8B5A2B), height: 1.5),
              ),
            ),

            const Spacer(),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.access_time),
                      label: const Text('Later'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5D3A1A),
                        side: const BorderSide(color: Color(0xFFD7C7B2)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                         Navigator.pop(context);
                         
                         final chatName = '${cow.breed} #${cow.id}';
                         final sellerName = cow.sellerName ?? 'Seller';
                         final chatId = await Provider.of<ChatService>(context, listen: false)
                             .startChat(chatName, sellerName);
                         
                         if (!context.mounted) return;
                         Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(
                           chatId: chatId,
                           name: sellerName,
                           avatar: '',
                           listingInfo: 'Interested in $chatName',
                         )));
                      },
                      icon: const Icon(Icons.chat_bubble),
                      label: const Text('Start Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Call Seller Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _callSeller(context),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Seller'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: const Color(0xFF3E2723),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('← Keep Moomingling', style: TextStyle(color: Color(0xFF9E8A78), fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
