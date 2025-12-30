class CowListing {
  final String id;
  final String name;
  final String breed;
  final double price;
  final String imageUrl;
  final bool isVerified;
  final String age;
  final String yieldAmount;
  final String location;
  final String? sellerName;
  final String? animalType;

  CowListing({
    required this.id,
    required this.name,
    required this.breed,
    required this.price,
    required this.imageUrl,
    required this.isVerified,
    required this.age,
    required this.yieldAmount,
    required this.location,
    this.sellerName,
    this.animalType,
  });

  factory CowListing.fromJson(Map<String, dynamic> json) {
    return CowListing(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'Unknown Cow',
      breed: json['breed'] ?? 'Unknown Breed',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      isVerified: json['is_verified'] == true,
      age: json['age']?.toString() ?? 'N/A',
      yieldAmount: json['yield_amount'] ?? 'N/A',
      location: json['location'] ?? 'Unknown',
      sellerName: json['seller_name'],
      animalType: json['animal_type'],
    );
  }
}
