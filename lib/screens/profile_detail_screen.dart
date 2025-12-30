import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'package:moomingle/services/chat_service.dart';
import 'package:moomingle/screens/chat_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileDetailScreen extends StatefulWidget {
  final CowListing cow;

  const ProfileDetailScreen({super.key, required this.cow});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isFavorite = false;

  CowListing get cow => widget.cow;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text(
          'PROFILE DETAILS',
          style: TextStyle(
              color: Color(0xFF8B5A2B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _toggleFavorite,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : const Color(0xFFC69C6D),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Avatar Header
                  Row(
                    children: [
                      Stack(
                        children: [
                           Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(cow.imageUrl),
                              onBackgroundImageError: (_, __) {},
                              child: cow.imageUrl.isEmpty 
                                  ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          if (cow.isVerified)
                             Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5E0C3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified, color: Color(0xFFE8B888), size: 28),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cow.name,
                              style: const TextStyle(
                                color: Color(0xFF5D3A1A),
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '#${cow.id}',
                              style: const TextStyle(
                                color: Color(0xFF9E8A78),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_formatPrice(cow.price)}',
                              style: const TextStyle(
                                color: Color(0xFFD3A15F),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cow.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEBC6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.verified, color: Color(0xFFDBB456), size: 16),
                              Text('Verified', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFFDBB456), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cow.isVerified)
                        _buildPill(Icons.fingerprint, 'Muzzle Verified'),
                      if (cow.isVerified) const SizedBox(width: 10),
                      _buildPill(Icons.location_on, cow.location),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // Gallery
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('GALLERY', style: TextStyle(color: Color(0xFF9E8A78), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGalleryItem(cow.imageUrl),
                        // Additional images would come from cow.additionalImages if available
                      ],
                    ),
                  ),

                   const SizedBox(height: 30),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        Icons.pets, 
                        'BREED', 
                        cow.breed, 
                        subTag: cow.isVerified ? 'AI Verified' : null, 
                        subTagColor: Colors.green[100],
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(Icons.cake, 'AGE', cow.age)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        Icons.water_drop, 
                        'PRODUCTION', 
                        cow.yieldAmount,
                        isGold: true,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(
                        Icons.location_on, 
                        'LOCATION', 
                        cow.location,
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Seller Info
                  if (cow.sellerName != null) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('SELLER', style: TextStyle(color: Color(0xFF9E8A78), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFD3A15F),
                            child: Text(
                              cow.sellerName![0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cow.sellerName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                const Text('Seller', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_user, color: Colors.green, size: 14),
                                SizedBox(width: 4),
                                Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [
                   const Color(0xFFF5E0C3).withValues(alpha: 0),
                   const Color(0xFFF5E0C3),
                 ],
                 stops: const [0.0, 0.3],
               )
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startChat(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D3A1A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline),
                        SizedBox(width: 8),
                        Text('Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showOfferDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A1A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on_outlined),
                        SizedBox(width: 8),
                        Text('Make Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _startChat(BuildContext context) async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final chatName = '${cow.breed} #${cow.id}';
    final chatId = await chatService.startChat(chatName, cow.sellerName ?? 'Seller');
    
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: chatId,
          name: cow.sellerName ?? 'Seller',
          avatar: '',
          listingInfo: 'Interested in $chatName',
        ),
      ),
    );
  }

  void _showOfferDialog(BuildContext context) {
    final offerController = TextEditingController(text: cow.price.toInt().toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Make an Offer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Listing price: ₹${_formatPrice(cow.price)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: offerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Offer (₹)',
                prefixText: '₹ ',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Quick offer buttons
            Row(
              children: [
                _buildQuickOfferChip(context, offerController, 0.9, '-10%'),
                const SizedBox(width: 8),
                _buildQuickOfferChip(context, offerController, 0.95, '-5%'),
                const SizedBox(width: 8),
                _buildQuickOfferChip(context, offerController, 1.0, 'Full'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Start chat with offer message
                  final chatService = Provider.of<ChatService>(context, listen: false);
                  final chatName = '${cow.breed} #${cow.id}';
                  final chatId = await chatService.startChat(chatName, cow.sellerName ?? 'Seller');
                  
                  final offerAmount = offerController.text;
                  chatService.sendMessage(chatId, 'Hi! I would like to make an offer of ₹$offerAmount for ${cow.name}.');
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offer sent! Check your messages.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        chatId: chatId,
                        name: cow.sellerName ?? 'Seller',
                        avatar: '',
                        listingInfo: 'Offer for $chatName',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Send Offer', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOfferChip(BuildContext context, TextEditingController controller, double multiplier, String label) {
    return GestureDetector(
      onTap: () {
        controller.text = (cow.price * multiplier).toInt().toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E0C3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D3A1A))),
      ),
    );
  }
  
  Widget _buildGalleryItem(String url) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFD3A15F))),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.pets, size: 40, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD3A15F)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Color(0xFF9E8A78), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, {String? subText, String? subTag, Color? subTagColor, bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isGold ?  const Color(0xFFD3A15F) : const Color(0xFFD7C7B2) ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF9E8A78), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF5D3A1A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(subText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
           if (subTag != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                color: subTagColor ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(subTag, style: TextStyle(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
