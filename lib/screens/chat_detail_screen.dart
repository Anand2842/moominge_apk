import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:moomingle/services/chat_service.dart';
import 'package:moomingle/widgets/safe_image.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String avatar;
  final String listingInfo;
  final String? sellerId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.avatar,
    this.listingInfo = 'Interested in listing',
    this.sellerId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _sharedImages = [];

  void _handleSend() {
    if (_messageController.text.trim().isEmpty) return;
    Provider.of<ChatService>(context, listen: false)
        .sendMessage(widget.chatId, _messageController.text.trim());
    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final bytes = await image.readAsBytes();
      setState(() => _sharedImages.add(bytes));
      
      Provider.of<ChatService>(context, listen: false)
          .sendMessage(widget.chatId, '📷 [Photo shared]');
      
      if (mounted) {
        _showImagePreview(bytes);
      }
    }
  }
  
  void _showImagePreview(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _viewSellerProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Seller Avatar
              SafeCircleAvatar(
                radius: 50, 
                imageUrl: widget.avatar.isNotEmpty ? widget.avatar : null,
                fallbackInitial: widget.name.isNotEmpty ? widget.name[0] : 'S',
              ),
              const SizedBox(height: 16),
              
              // Seller Name
              Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Info text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.listingInfo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _requestPhoneNumber();
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Request Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.chat),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2723),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestPhoneNumber() {
    // Send a message requesting phone number
    Provider.of<ChatService>(context, listen: false)
        .sendMessage(widget.chatId, '📞 Hi! I would like to discuss this listing over a call. Could you please share your phone number?');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call request sent! The seller will share their number if interested.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSendPriceModal() {
    final priceController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Send Price Quote', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (₹)',
                prefixText: '₹ ',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (priceController.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    Provider.of<ChatService>(context, listen: false)
                        .sendMessage(widget.chatId, '💰 Price Quote: ₹${priceController.text}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Send Price', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLocation() {
    Provider.of<ChatService>(context, listen: false)
        .sendMessage(widget.chatId, '📍 Location shared');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location shared!'), backgroundColor: Colors.green),
    );
  }

  void _requestVideo() {
    Provider.of<ChatService>(context, listen: false)
        .sendMessage(widget.chatId, '🎥 Can you please share a video of the cattle? I would like to see it walking and its overall condition.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video request sent!'), backgroundColor: Colors.green),
    );
  }

  void _showScheduleVisitModal() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Schedule Visit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFFD3A15F)),
                title: const Text('Date'),
                subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFFD3A15F)),
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(ctx)),
                onTap: () async {
                  final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (time != null) setModalState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final dateStr = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                    final timeStr = selectedTime.format(context);
                    Provider.of<ChatService>(context, listen: false)
                        .sendMessage(widget.chatId, '📅 Visit Request: I would like to visit on $dateStr at $timeStr. Please confirm if this works for you.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Visit request sent!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Send Request', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.grey),
              title: const Text('Delete Chat'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E0C3),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: GestureDetector(
          onTap: _viewSellerProfile,
          child: Row(
            children: [
              Stack(
                children: [
                  SafeCircleAvatar(
                    radius: 20, 
                    imageUrl: widget.avatar.isNotEmpty ? widget.avatar : null,
                    fallbackInitial: widget.name.isNotEmpty ? widget.name[0] : 'U',
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD3A15F), borderRadius: BorderRadius.circular(10)),
                          child: const Text('MATCHED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.listingInfo, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(onPressed: _showMoreOptions, icon: const Icon(Icons.more_vert, color: Color(0xFF5D3A1A))),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('TODAY', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<ChatService>(
                  builder: (context, chatService, child) {
                    final chat = chatService.getChatById(widget.chatId);
                    if (chat == null) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('Start the conversation!', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    
                    final messages = chat['messages'];
                    if (messages == null || messages is! List || messages.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('Start the conversation!', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    
                    return Column(
                      children: messages.map<Widget>((msg) {
                        if (msg is! Map<String, dynamic>) {
                          return const SizedBox.shrink();
                        }
                        return _buildMessage(msg);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(Icons.attach_money, 'Send Price', _showSendPriceModal),
                  const SizedBox(width: 8),
                  _buildQuickAction(Icons.location_on, 'Share Location', _shareLocation),
                  const SizedBox(width: 8),
                  _buildQuickAction(Icons.videocam, 'Request Video', _requestVideo),
                  const SizedBox(width: 8),
                  _buildQuickAction(Icons.schedule, 'Schedule Visit', _showScheduleVisitModal),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickAndSendImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_photo_alternate, color: Color(0xFF5D3A1A)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(hintText: 'Message...', border: InputBorder.none),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(color: Color(0xFFD3A15F), shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true; // Safe bool check
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            SafeCircleAvatar(
              radius: 16, 
              imageUrl: widget.avatar.isNotEmpty ? widget.avatar : null,
              fallbackInitial: widget.name.isNotEmpty ? widget.name[0] : 'U',
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF5D3A1A) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4), bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                ),
                child: Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : const Color(0xFF3E2723))),
              ),
              const SizedBox(height: 4),
              Text(msg['time'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF5D3A1A)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
