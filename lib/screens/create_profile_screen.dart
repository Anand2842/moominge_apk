import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:typed_data';
import 'package:moomingle/screens/role_selection_screen.dart';
import 'package:moomingle/services/user_profile_service.dart';
import 'package:moomingle/services/auth_service.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String? _selectedRole;
  String? _selectedState;
  String? _selectedDistrict;
  bool _isDetectingLocation = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _avatarBytes;

  final List<String> _states = [
    'Haryana', 'Gujarat', 'Punjab', 'Rajasthan', 'Uttar Pradesh', 
    'Maharashtra', 'Madhya Pradesh', 'Karnataka', 'Tamil Nadu', 'Andhra Pradesh'
  ];
  
  // District data by state
  final Map<String, List<String>> _districtsByState = {
    'Haryana': ['Rohtak', 'Hisar', 'Karnal', 'Panipat', 'Sonipat', 'Gurugram', 'Faridabad', 'Ambala', 'Kurukshetra', 'Jhajjar'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar', 'Junagadh', 'Gandhinagar', 'Kutch', 'Anand'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali', 'Pathankot', 'Hoshiarpur', 'Moga', 'Firozpur'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer', 'Alwar', 'Bharatpur', 'Sikar', 'Nagaur'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly', 'Aligarh', 'Moradabad', 'Ghaziabad'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Solapur', 'Kolhapur', 'Sangli', 'Satara', 'Ahmednagar'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar', 'Dewas', 'Satna', 'Ratlam', 'Rewa'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum', 'Gulbarga', 'Davangere', 'Bellary', 'Bijapur', 'Shimoga'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Tirunelveli', 'Erode', 'Vellore', 'Thoothukudi', 'Dindigul'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool', 'Rajahmundry', 'Tirupati', 'Kakinada', 'Kadapa', 'Anantapur'],
  };

  Future<void> _autoDetectLocation() async {
    setState(() => _isDetectingLocation = true);
    
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final detectedState = place.administrativeArea ?? '';
        final detectedDistrict = place.locality ?? place.subAdministrativeArea ?? '';
        
        // Match with our state list
        String? matchedState;
        for (final state in _states) {
          if (detectedState.toLowerCase().contains(state.toLowerCase()) ||
              state.toLowerCase().contains(detectedState.toLowerCase())) {
            matchedState = state;
            break;
          }
        }
        
        setState(() {
          _selectedState = matchedState ?? detectedState;
          _selectedDistrict = detectedDistrict;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location detected: $detectedDistrict, ${matchedState ?? detectedState}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not detect location: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _pickAvatar() async {
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
            const Text('Choose Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF5D3A1A)),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  final bytes = await photo.readAsBytes();
                  setState(() => _avatarBytes = bytes);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF5D3A1A)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                if (photo != null) {
                  final bytes = await photo.readAsBytes();
                  setState(() => _avatarBytes = bytes);
                }
              },
            ),
            if (_avatarBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _avatarBytes = null);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5D3A1A)),
        title: const Text(
          'Create Profile',
          style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _navigateToRoleSelection(),
            child: const Text('Skip', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD7C7B2), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 30),
            
            const Text(
              "Let's get to know you",
              style: TextStyle(color: Color(0xFF3E2723), fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your details to connect with others',
              style: TextStyle(color: Color(0xFF8B5A2B), fontSize: 14),
            ),
            
            const SizedBox(height: 30),
            
            // Avatar - Now tappable
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFE8D6C0),
                      backgroundImage: _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                      child: _avatarBytes == null 
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF3E2723), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Full Name
            const Text('Full Name', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Ramesh Singh',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Phone Number (Optional)
            const Text('Phone Number (Optional)', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91 99999 99999',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.phone, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Role Selection
            const Text('I am a...', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRoleChip('Farmer', Icons.agriculture, 'farmer'),
                const SizedBox(width: 12),
                _buildRoleChip('Trader', Icons.store, 'trader'),
                const SizedBox(width: 12),
                _buildRoleChip('Dairy\nOwner', Icons.water_drop, 'dairy'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Location
            const Text('Location Details', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Auto-detect button
            GestureDetector(
              onTap: _isDetectingLocation ? null : _autoDetectLocation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF6EE),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFD3A15F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isDetectingLocation)
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD3A15F)),
                      )
                    else
                      const Icon(Icons.my_location, color: Color(0xFFD3A15F), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isDetectingLocation ? 'Detecting...' : 'Auto-detect Location',
                      style: const TextStyle(color: Color(0xFFD3A15F), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // State & District dropdowns
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showStatePicker(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedState ?? 'State', style: TextStyle(color: _selectedState != null ? Colors.black : Colors.grey)),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDistrictPicker(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedDistrict ?? 'District', style: TextStyle(color: _selectedDistrict != null ? Colors.black : Colors.grey)),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
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
            onPressed: () => _navigateToRoleSelection(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E2723),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoleSelection() {
    // Save profile data before navigating
    final profileService = context.read<UserProfileService>();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _selectedDistrict != null && _selectedState != null
        ? '$_selectedDistrict, $_selectedState'
        : _selectedState;
    
    if (name.isNotEmpty || phone.isNotEmpty || location != null) {
      profileService.updateProfile(
        name: name.isNotEmpty ? name : null,
        phone: phone.isNotEmpty ? phone : null,
        location: location,
      );
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  void _showStatePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select State', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _states.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_states[index]),
                  trailing: _selectedState == _states[index] 
                      ? const Icon(Icons.check, color: Color(0xFFD3A15F))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedState = _states[index];
                      _selectedDistrict = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistrictPicker() {
    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a state first')),
      );
      return;
    }
    
    final districts = _districtsByState[_selectedState] ?? ['District 1', 'District 2', 'District 3'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select District', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: districts.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(districts[index]),
                  trailing: _selectedDistrict == districts[index]
                      ? const Icon(Icons.check, color: Color(0xFFD3A15F))
                      : null,
                  onTap: () {
                    setState(() => _selectedDistrict = districts[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, IconData icon, String value) {
    bool isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: const Color(0xFFD3A15F), width: 2) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF5D3A1A)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF5D3A1A), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
