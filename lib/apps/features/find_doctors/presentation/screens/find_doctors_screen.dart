import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class FindDoctorsScreen extends StatefulWidget {
  const FindDoctorsScreen({super.key});

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _doctors = const [
    {
      'name': 'Dr. Shruti Kedia',
      'specialty': 'Tooth Dentist',
      'experience': '7 Years experience',
      'available': 'Next Available\n10:00 AM tomorrow',
    },
    {
      'name': 'Dr. Watamaniuk',
      'specialty': 'Tooth Dentist',
      'experience': '9 Years experience',
      'available': 'Next Available\n12:00 AM tomorrow',
    },
    {
      'name': 'Dr. Crownover',
      'specialty': 'Tooth Dentist',
      'experience': '5 Years experience',
      'available': 'Next Available\n11:00 AM tomorrow',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text('Find Doctors', style: context.bold16TextMain),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSub),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Dentist',
                        hintStyle: context.regular14TextSub,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const Icon(Icons.close, color: AppColors.textSub, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return _buildDoctorListCard(
                    context,
                    name: doctor['name']!,
                    specialty: doctor['specialty']!,
                    experience: doctor['experience']!,
                    available: doctor['available']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorListCard(
    BuildContext context, {
    required String name,
    required String specialty,
    required String experience,
    required String available,
  }) {
    return GestureDetector(
      onTap: () => context.push('/doctor-details'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textBorders),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.grey100,
              child: Icon(Icons.person, color: AppColors.textSub, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: context.semiBold14TextMain),
                      const Icon(
                        Icons.favorite,
                        color: AppColors.danger,
                        size: 18,
                      ),
                    ],
                  ),
                  Text(specialty, style: context.regular12TextSub),
                  const SizedBox(height: 2),
                  Text(experience, style: context.regular11TextSub),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          available,
                          style: context.regular11TextSub,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/doctor-details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: context.semiBold12White,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
