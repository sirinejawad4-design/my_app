import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class HomeScreen extends StatelessWidget {//statewidget hon m fi aya value btetghyrbb hed screen hon bs 3ared sebt
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(//btkhli scrren kela kabile la nshba la foe w tht
          child: Column(//btrtb kl parts foe baad
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(//by3rod kl cheche
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: AppColors.primary,//baclground khdra
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
  'Hi ${FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'there'},',
  style: context.regular14White,
),
                    const SizedBox(height: 4),
                    Text('Find Your Doctor', style: context.bold22White),
                    const SizedBox(height: 16),
                    GestureDetector(//chrit search
                      onTap: () => context.push('/find-doctors'),//lama ef2su bruh la sfht finfdoctor use push krml nrjaa
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textSub),
                            const SizedBox(width: 8),
                            Expanded(
                              child: IgnorePointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: context.regular14TextSub,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionHeader(context, 'Live Doctors', showSeeAll: false),
              SizedBox(
                height: 90,//hadadna space bs bi ertif3 0 pixel bs la ossem hed
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,//khliya tethrak yamin chmel
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,//kareru 3 marat
                  separatorBuilder: (_, __) => const SizedBox(width: 12),//elfasl 12 pixel bynton
                  itemBuilder: (context, index) => Container(//kalb nafsu yani chkl kl 3nsor yaani de2ira green bi icunet tchghil
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grey100,
                    ),
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryIcon(Icons.medical_services, AppColors.secondary),
                    _buildCategoryIcon(Icons.favorite, AppColors.success),
                    _buildCategoryIcon(Icons.visibility, AppColors.warning),
                    _buildCategoryIcon(Icons.accessibility_new, AppColors.danger),
                  ],
                ),
              ),

              const SizedBox(height: 24),//nfs fkrt listview bs fare2 badl m ykun container basit hon kl 3nsor huwe natijt la aayt la function builddoctorcard maa malumt mhdide

              _buildSectionHeader(context, 'Popular Doctor'),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _buildDoctorCard(
                    context,
                    name: 'Dr. Fillerup Grab',
                    specialty: 'Medicine Specialist',
                    rating: 4.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),//nafs fkrt listview bs bdun scrolldirection yaani by default bsir 3amudi mn foe la tht

              _buildSectionHeader(context, 'Category', showSeeAll: false),
              ListView.separated(
                shrinkWrap: true,//bi oul la flutter nekhod bs space mhtejina mch kl scren 
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildCategoryListTile(
                  context,
                  name: 'Dr. Pediatrician',
                  specialty: 'Specialist Cardiologist',
                  rating: 2.4,
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Feature Doctor'),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => context.push('/doctor-details'),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.grey100,
                          child: Icon(Icons.person, color: AppColors.textSub),
                        ),
                        const SizedBox(height: 4),
                        Text('Dr. Criss', style: context.regular12TextMain),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool showSeeAll = true,//value ekhtirye by default true yaani iza m hadadt chi byzhr seeall
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.bold16TextMain),
          if (showSeeAll) Text('See all', style: context.regular12Primary),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, Color color) {
    return Container(//icon heart..
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildDoctorCard(
    BuildContext context, {
    required String name,
    required String specialty,
    required double rating,
  }) {
    return GestureDetector(
      onTap: () => context.push('/doctor-details'),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textBorders),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.grey100,
              child: Icon(Icons.person, color: AppColors.textSub),
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
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.warning),
                const SizedBox(width: 2),
                Text('$rating', style: context.regular11TextSub),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListTile(
    BuildContext context, {
    required String name,
    required String specialty,
    required double rating,
  }) {
    return GestureDetector(
      onTap: () => context.push('/doctor-details'),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.grey100,
            child: Icon(Icons.person, color: AppColors.textSub),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.semiBold14TextMain),
                Text(specialty, style: context.regular12TextSub),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.warning),
              const SizedBox(width: 2),
              Text('$rating', style: context.regular12TextSub),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.favorite_border, color: AppColors.danger, size: 20),
        ],
      ),
    );
  }
}