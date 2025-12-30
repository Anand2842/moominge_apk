import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(50000, 200000);
  RangeValues _milkRange = const RangeValues(5, 20);
  RangeValues _ageRange = const RangeValues(2, 8);
  double _distance = 100;
  final Set<String> _selectedBreeds = {'Gir', 'Murrah'};
  
  // Toggle states for switches
  bool _verifiedOnly = true;
  bool _withHealthCert = false;
  bool _pregnantOnly = false;
  
  // All 50 breeds supported by the ML model
  final List<String> _buffaloBreeds = [
    'Murrah', 'Jaffarbadi', 'Mehsana', 'Bhadawari', 'Surti',
    'Nili-Ravi', 'Pandharpuri', 'Nagpuri', 'Toda', 'Chilika',
  ];
  
  final List<String> _cattleBreeds = [
    'Gir', 'Kankrej', 'Ongole', 'Sahiwal', 'Tharparkar',
    'Red Sindhi', 'Rathi', 'Hariana', 'Deoni', 'Hallikar',
    'Amritmahal', 'Khillari', 'Kangayam', 'Bargur', 'Punganur',
    'Vechur', 'Kasaragod', 'Malnad Gidda', 'Krishna Valley', 'Dangi',
    'Gaolao', 'Nimari', 'Kenkatha', 'Ponwar', 'Bachaur',
    'Siri', 'Mewati', 'Nagori', 'Malvi', 'Kherigarh',
    'Gangatiri', 'Belahi', 'Lohani', 'Rojhan', 'Dajal',
    'Bhagnari', 'Dhanni', 'Cholistani', 'Achai', 'Lakhani',
  ];
  
  List<String> get _breeds => [..._buffaloBreeds, ..._cattleBreeds];

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
        title: const Text('Filters', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _priceRange = const RangeValues(50000, 200000);
              _milkRange = const RangeValues(5, 20);
              _ageRange = const RangeValues(2, 8);
              _distance = 100;
              _selectedBreeds.clear();
              _verifiedOnly = false;
              _withHealthCert = false;
              _pregnantOnly = false;
            }),
            child: const Text('Reset', style: TextStyle(color: Color(0xFFD3A15F))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breed Selection
            const Text('BREED', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _breeds.map((breed) {
                final isSelected = _selectedBreeds.contains(breed);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedBreeds.remove(breed);
                    } else {
                      _selectedBreeds.add(breed);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF3E2723) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF3E2723) : Colors.grey.shade300),
                    ),
                    child: Text(breed, style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3E2723),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Price Range
            _buildSliderSection(
              'PRICE RANGE',
              '₹${(_priceRange.start / 1000).toInt()}K - ₹${(_priceRange.end / 1000).toInt()}K',
              RangeSlider(
                values: _priceRange,
                min: 10000,
                max: 500000,
                divisions: 49,
                activeColor: const Color(0xFFD3A15F),
                inactiveColor: Colors.grey.shade300,
                onChanged: (values) => setState(() => _priceRange = values),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Distance
            _buildSliderSection(
              'DISTANCE',
              '${_distance.toInt()} km',
              Slider(
                value: _distance,
                min: 0,
                max: 500,
                divisions: 50,
                activeColor: const Color(0xFFD3A15F),
                inactiveColor: Colors.grey.shade300,
                onChanged: (value) => setState(() => _distance = value),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Milk Yield
            _buildSliderSection(
              'MILK YIELD (per day)',
              '${_milkRange.start.toInt()} - ${_milkRange.end.toInt()} liters',
              RangeSlider(
                values: _milkRange,
                min: 0,
                max: 40,
                divisions: 40,
                activeColor: const Color(0xFFD3A15F),
                inactiveColor: Colors.grey.shade300,
                onChanged: (values) => setState(() => _milkRange = values),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Age Range
            _buildSliderSection(
              'AGE',
              '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} years',
              RangeSlider(
                values: _ageRange,
                min: 1,
                max: 15,
                divisions: 14,
                activeColor: const Color(0xFFD3A15F),
                inactiveColor: Colors.grey.shade300,
                onChanged: (values) => setState(() => _ageRange = values),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional Filters
            const Text('MORE FILTERS', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Verified Sellers Only', style: TextStyle(color: Color(0xFF3E2723))),
                    value: _verifiedOnly,
                    activeTrackColor: const Color(0xFFD3A15F),
                    activeColor: Colors.white,
                    onChanged: (value) => setState(() => _verifiedOnly = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('With Health Certificate', style: TextStyle(color: Color(0xFF3E2723))),
                    value: _withHealthCert,
                    activeTrackColor: const Color(0xFFD3A15F),
                    activeColor: Colors.white,
                    onChanged: (value) => setState(() => _withHealthCert = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Pregnant', style: TextStyle(color: Color(0xFF3E2723))),
                    value: _pregnantOnly,
                    activeTrackColor: const Color(0xFFD3A15F),
                    activeColor: Colors.white,
                    onChanged: (value) => setState(() => _pregnantOnly = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E0C3),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Matching Results', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(_getResultsText(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Return filter results to previous screen
                  Navigator.pop(context, {
                    'breeds': _selectedBreeds.toList(),
                    'priceRange': _priceRange,
                    'distance': _distance,
                    'milkRange': _milkRange,
                    'ageRange': _ageRange,
                    'verifiedOnly': _verifiedOnly,
                    'withHealthCert': _withHealthCert,
                    'pregnantOnly': _pregnantOnly,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateResults() {
    // Return a placeholder - actual filtering happens in home_screen
    // The real count would require a database query with all filters
    // For now, indicate that filters will be applied
    if (_selectedBreeds.isEmpty && !_verifiedOnly && !_withHealthCert && !_pregnantOnly) {
      return 0; // Will show "All listings"
    }
    return -1; // Indicates filters are active
  }

  String _getResultsText() {
    final count = _calculateResults();
    if (count == 0) return 'All listings';
    return 'Filters active';
  }

  Widget _buildSliderSection(String title, String value, Widget slider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            ],
          ),
          const SizedBox(height: 8),
          slider,
        ],
      ),
    );
  }
}
