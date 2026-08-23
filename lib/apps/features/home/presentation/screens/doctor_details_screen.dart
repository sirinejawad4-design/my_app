import 'package:flutter/material.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final double rating;
  final String price;

  const DoctorDetailsScreen({
    super.key,
    this.doctorName = 'Dr. Pediatrician',
    this.specialty = 'Specialist Cardiologist',
    this.rating = 4.0,
    this.price = '\$28.00/hr',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text('Doctor Details', style: context.bold16TextMain),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كرت معلومات الدكتور الأساسية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.grey100,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.person,
                      color: AppColors.textSub,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                doctorName,
                                style: context.semiBold16TextMain,
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: AppColors.danger,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(specialty, style: context.regular12TextSub),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(price, style: context.semiBold12TextMain),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // زرار Book Now
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Book Now', style: context.semiBold16White),
              ),
            ),

            const SizedBox(height: 24),

            // الإحصائيات (Rating, Ongoing, Patient)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(context, '100', 'Rating'),
                _buildStat(context, '500', 'Ongoing'),
                _buildStat(context, '700', 'Patient'),
              ],
            ),

            const SizedBox(height: 24),

            // قسم Services
            Text('Services', style: context.bold16TextMain),
            const SizedBox(height: 12),
            _buildServiceItem(
              context,
              1,
              'Patient care should be the number one priority',
            ),
            _buildServiceItem(
              context,
              2,
              'If you run your practice, you know how frustrating scheduling can be',
            ),
            _buildServiceItem(
              context,
              3,
              "That's why some of appointment reminder system is used",
            ),

            const SizedBox(height: 24),

            // خريطة توضيحية (placeholder مؤقت)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.map_outlined,
                  color: AppColors.textSub,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // عنصر إحصائية واحدة (Rating/Ongoing/Patient)
  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: context.bold18TextMain),
        const SizedBox(height: 2),
        Text(label, style: context.regular12TextSub),
      ],
    );
  }

  // عنصر خدمة واحدة برقم مرقّم
  Widget _buildServiceItem(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: context.semiBold14TextMain),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: context.regular12TextSub),
          ),
        ],
      ),
    );
  }
}