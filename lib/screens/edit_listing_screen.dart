import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moomingle/services/api_service.dart';
import 'package:moomingle/services/seller_stats_service.dart';
import 'package:moomingle/services/auth_service.dart';

class EditListingScreen extends StatefulWidget {
  final SellerListing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _ageController;
  late TextEditingController _yieldController;
  late TextEditingController _locationController;
  
  String _selectedBreed = 'Murrah';
  String _selectedAnimalType = 'Buffalo';
  bool _isLoading = false;

  final List<String> _buffaloBreeds = ['Murrah', 'Jaffarbadi', 'Mehsana', 'Bhadawari', 'Surti'];
  final List<String> _cattleBreeds = ['Gir', 'Kankrej', 'Sahiwal', 'Ongole', 'Tharparkar'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing.breed);
    _priceController = TextEditingController(text: widget.listing.price.toInt().toString());
    _ageController = TextEditingController(text: '4');
    _yieldController = TextEditingController(text: '15');
    _locationController = TextEditingController(text: '');
    _selectedBreed = widget.listing.breed;
    
    // Determine animal type from breed
    if (_buffaloBreeds.contains(widget.listing.breed)) {
      _selectedAnimalType = 'Buffalo';
    } else {
      _selectedAnimalType = 'Cattle';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ageController.dispose();
    _yieldController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  List<String> get _currentBreeds => _selectedAnimalType == 'Buffalo' ? _buffaloBreeds : _cattleBreeds;

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiService = context.read<ApiService>();
    final success = await apiService.updateListing(
      id: widget.listing.id,
      name: _nameController.text.trim(),
      breed: _selectedBreed,
      price: double.tryParse(_priceController.text) ?? widget.listing.price,
      age: '${_ageController.text} Years',
      yieldAmount: '${_yieldController.text}L / Day',
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      animalType: _selectedAnimalType,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Refresh seller listings
      final auth = context.read<AuthService>();
      await context.read<SellerStatsService>().fetchSellerListings(auth.user?.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E0C3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text('Edit Listing', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Image Preview
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.listing.imageUrl.isNotEmpty
                      ? Image.network(widget.listing.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder())
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(height: 24),

              // Animal Type Selection
              const Text('Animal Type', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTypeChip('Buffalo', _selectedAnimalType == 'Buffalo')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTypeChip('Cattle', _selectedAnimalType == 'Cattle')),
                ],
              ),
              const SizedBox(height: 20),

              // Breed Selection
              const Text('Breed', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentBreeds.contains(_selectedBreed) ? _selectedBreed : _currentBreeds.first,
                    isExpanded: true,
                    items: _currentBreeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _selectedBreed = v!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('e.g., Royal Murrah'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Price
              const Text('Price (₹)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: _inputDecoration('e.g., 85000'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Age & Yield Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Age (Years)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                        const SizedBox(height: 8),
                        TextFormField(controller: _ageController, decoration: _inputDecoration('4'), keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yield (L/Day)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                        const SizedBox(height: 8),
                        TextFormField(controller: _yieldController, decoration: _inputDecoration('15'), keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location
              const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 8),
              TextFormField(controller: _locationController, decoration: _inputDecoration('e.g., Rohtak, Haryana')),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.pets, size: 48, color: Colors.grey)));
  }

  Widget _buildTypeChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAnimalType = label;
        _selectedBreed = _currentBreeds.first;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E2723) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF3E2723), fontWeight: FontWeight.bold))),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
