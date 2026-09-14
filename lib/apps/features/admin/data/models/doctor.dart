class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
