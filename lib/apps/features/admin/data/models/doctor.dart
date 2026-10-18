class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double fee;
  final double rating;
  final int reviewsCount;
  final bool isActive;
  final Map<String, bool> workingDays;
  final String startTime;
  final String endTime;
  final int slotDuration;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.fee,
    required this.rating,
    required this.reviewsCount,
    required this.isActive,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    final rawWorkingDays = data['workingDays'];

    final Map<String, bool> workingDays = rawWorkingDays is Map
        ? rawWorkingDays.map<String, bool>(
            (key, value) => MapEntry(key.toString(), value == true),
          )
        : {
            'monday': false,
            'tuesday': false,
            'wednesday': false,
            'thursday': false,
            'friday': false,
            'saturday': false,
            'sunday': false,
          };

    return Doctor(
      id: id,

      name: data['name'] is String ? data['name'] as String : '',

      specialty: data['specialty'] is String ? data['specialty'] as String : '',

      imageUrl: data['imageUrl'] is String ? data['imageUrl'] as String : '',

      fee: data['fee'] is num ? (data['fee'] as num).toDouble() : 0.0,

      rating: data['rating'] is num ? (data['rating'] as num).toDouble() : 0.0,

      reviewsCount: data['reviewsCount'] is num
          ? (data['reviewsCount'] as num).toInt()
          : 0,

      isActive: data['isActive'] is bool ? data['isActive'] as bool : true,

      workingDays: workingDays,

      startTime: data['startTime'] is String
          ? data['startTime'] as String
          : '09:00 AM',

      endTime: data['endTime'] is String
          ? data['endTime'] as String
          : '05:00 PM',

      slotDuration: data['slotDuration'] is num
          ? (data['slotDuration'] as num).toInt()
          : 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'fee': fee,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isActive': isActive,
      'workingDays': workingDays,
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDuration,
    };
  }
}
