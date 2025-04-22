class Mekanik {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final String address;
  final String location;
  final String image;
  final String description;
  final String price;
  final bool availability;
  final String email; 
  final String phone; 

  Mekanik({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.address,
    required this.location,
    required this.image,
    required this.description,
    required this.price,
    required this.availability,
    required this.email,
    required this.phone, 
  });

  factory Mekanik.fromMap(Map<String, dynamic> map) {
    return Mekanik(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      rating: map['rating'].toDouble(),
      address: map['address'],
      location: map['location'],
      image: map['image'],
      description: map['description'],
      price: map['price'],
      availability: map['availability'],
      email: map['email'], 
      phone: map['phone'],
    );
  }
}
