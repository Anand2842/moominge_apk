import 'package:flutter/material.dart';
import 'package:moomingle/screens/listing_verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/api_service.dart';
import 'package:moomingle/models/cow_listing.dart';
import 'dart:math';

class AddDetailsScreen extends StatefulWidget {
  final String? initialBreed;
  const AddDetailsScreen({super.key, this.initialBreed});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  int _milkYield = 0;
  int _lactation = 2;
  int _offspring = 1;
  String _pregnancy = '3 Months';
  int _price = 85000;
  bool _showIssueCard = true;
  
  late String _selectedBreed;
  final List<String> _breeds = [
    'Murrah', 'Jaffarbadi', 'Mehsana', 'Bhadawari', 'Surti',
    'Gir', 'Kankrej', 'Ongole', 'Sahiwal', 'Tharparkar',
    'Holstein Friesian', 'Jersey', 'Brown Swiss', 'Ayrshire', 'Red Dane'
  ];
  
  @override
  void initState() {
    super.initState();
    _selectedBreed = widget.initialBreed ?? 'Murrah';
    // Ensure selected breed is in the list (handle AI returning unlisted breed)
    if (!_breeds.contains(_selectedBreed)) {
        if (_breeds.isNotEmpty) _selectedBreed = _breeds[0];
    }
  }

  final List<String> _pregnancyOptions = [
    'Not Pregnant', '1 Month', '2 Months', '3 Months', '4 Months', 
    '5 Months', '6 Months', '7 Months', '8 Months', '9 Months'
  ];

  String _location = 'Near Karnal, Haryana';

  void _showPregnancyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pregnancy Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _pregnancyOptions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_pregnancyOptions[index]),
                  trailing: _pregnancy == _pregnancyOptions[index]
                      ? const Icon(Icons.check, color: Color(0xFFD3A15F))
                      : null,
                  onTap: () {
                    setState(() => _pregnancy = _pregnancyOptions[index]);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationEditor() {
    final locationController = TextEditingController(text: _location);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                locationController.text = 'Rohtak, Haryana (Auto-detected)';
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD3A15F)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.my_location, color: Color(0xFFD3A15F), size: 18),
                    SizedBox(width: 8),
                    Text('Use Current Location', style: TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _location = locationController.text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Save Location', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  final Map<String, String> _breedImages = {
    'Murrah': 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Murrah_buffalo.JPG',
    'Jaffarbadi': 'https://upload.wikimedia.org/wikipedia/commons/c/c5/Jafarabadi_buffalo_in_village.jpg',
    'Mehsana': 'https://upload.wikimedia.org/wikipedia/commons/1/10/Water_buffalo_bull%2C_near_Mehsana%2C_Gujarat%2C_India%2C_2.jpg',
    'Bhadawari': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Buffalo_Breeds.jpg/640px-Buffalo_Breeds.jpg',
    'Surti': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Bubalus_bubalis_in_India.jpg/640px-Bubalus_bubalis_in_India.jpg',
    'Gir': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Gir_cattle.jpg/800px-Gir_cattle.jpg',
    'Kankrej': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Kankrej_cattle.jpg/800px-Kankrej_cattle.jpg',
    'Ongole': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Ongole_Bull.jpg/800px-Ongole_Bull.jpg',
    'Sahiwal': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Sahiwal_Cow.jpg/800px-Sahiwal_Cow.jpg',
    'Tharparkar': 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Tharparkar_Cattle.jpg',
    'Holstein Friesian': 'https://upload.wikimedia.org/wikipedia/commons/2/23/Holstein_dairy_cow_and_calf.jpg',
    'Jersey': 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Jersey_cow_peering.jpg',
    'Brown Swiss': 'https://upload.wikimedia.org/wikipedia/commons/2/25/Braunvieh_im_Allg%C3%A4u_03.jpg',
    'Ayrshire': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Ayrshire_Cattle.jpg',
    'Red Dane': 'https://upload.wikimedia.org/wikipedia/commons/3/36/RDM_Kuh.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.close, color: Color(0xFF5D3A1A)),
          ),
        ),
        title: const Text('Add Details', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Draft Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD3A15F)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _breedImages[_selectedBreed] ?? 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=100',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DRAFT #092', style: TextStyle(fontSize: 12, color: Color(0xFFD3A15F), fontWeight: FontWeight.bold)),
                        Text(_selectedBreed, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                        const Text('Ready to edit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Breed Selector
            const Text('Breed', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBreed,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD3A15F)),
                  items: _breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) => setState(() => _selectedBreed = v!),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Milk & Lactation
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Milk (L/day)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$_milkYield', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                            const Text('L', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lactation #', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _lactation = (_lactation - 1).clamp(0, 10)),
                              icon: const Icon(Icons.remove, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                            ),
                            Text('$_lactation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => setState(() => _lactation++),
                              icon: const Icon(Icons.add, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Offspring & Pregnancy
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Offspring', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(color: Color(0xFFD3A15F), shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () => setState(() => _offspring = (_offspring - 1).clamp(0, 20)),
                                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                              ),
                            ),
                            Text('$_offspring', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              decoration: const BoxDecoration(color: Color(0xFFD3A15F), shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () => setState(() => _offspring++),
                                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pregnancy', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showPregnancyPicker(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_pregnancy, style: const TextStyle(fontSize: 16)),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Issue Warning Card
            if (_showIssueCard)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red[100], shape: BoxShape.circle),
                      child: const Icon(Icons.medical_services, color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Possible Issue Detected', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                          Text('We analyzed your photo and found a possible scar on the rear leg.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_showIssueCard)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => setState(() => _showIssueCard = false), child: const Text('Dismiss', style: TextStyle(color: Colors.grey))),
                    TextButton(onPressed: () {
                      setState(() => _showIssueCard = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Issue confirmed and noted in listing'), backgroundColor: Colors.orange),
                      );
                    }, child: const Text('Confirm Issue', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Price
            const Text('Asking Price', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                    child: const Text('₹', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      controller: TextEditingController(text: '$_price'),
                      onChanged: (v) => _price = int.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Location
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_location, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('GPS Precision: High', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () => _showLocationEditor(), child: const Text('Edit', style: TextStyle(color: Color(0xFFD3A15F)))),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF5E0C3),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              // Create new listing
              final newCow = CowListing(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'New Listing #${Random().nextInt(100)}',
                breed: _selectedBreed,
                price: _price.toDouble(),
                imageUrl: _breedImages[_selectedBreed] ?? 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=800',
                isVerified: false,
                age: '$_lactation Lactations',
                yieldAmount: '$_milkYield L/Day',
                location: 'Karnal, Haryana',
              );

              // Submit to store
              Provider.of<ApiService>(context, listen: false).addListing(newCow);

              Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingVerificationScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD3A15F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Post to Moomingle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
