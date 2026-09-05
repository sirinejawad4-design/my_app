import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _favouriteDoctors = const [
    {
      'name': 'Dr. Shouey',
      'specialty': 'Specialist Medicine',
    },
    {
      'name': 'Dr. Christenfeld N',
      'specialty': 'Specialist Cancer',
    },
    {
      'name': 'Dr. Mistry Brick',
      'specialty': 'Specialist Dentist',
    },
    {
      'name': 'Dr. Ether Wall',
      'specialty': 'Specialist Cancer',
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
        title: Text('Favourite Doctors', style: context.bold16TextMain),
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
              child: _favouriteDoctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: AppColors.textSub,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No favourite doctors yet',
                            style: context.regular14TextSub,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _favouriteDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _favouriteDoctors[index];
                        return _buildFavouriteCard(
                          context,
                          name: doctor['name']!,
                          specialty: doctor['specialty']!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(
    BuildContext context, {
    required String name,
    required String specialty,
  }) {
    return GestureDetector(
      onTap: () => context.push('/doctor-details'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textBorders),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.grey100,
                  child: Icon(Icons.person, color: AppColors.textSub),
                ),
                const Icon(Icons.favorite, color: AppColors.danger, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: context.semiBold12TextMain,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              specialty,
              style: context.regular11TextSub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}