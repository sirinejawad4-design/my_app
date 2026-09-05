import 'package:flutter/material.dart';
import '../../../../../generated/app_colors.dart';
import 'home_screen.dart';
import 'favourites_screen.dart';
//fi charit tankol(home fav appointment mess)juwtu contnt bytghyr hasab aya tab f2st
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;//huwe raem bytzkr aya tab fthinu halaae w kwnu blchna mn zero
  //so awal m app yftah fa tab home huwe mftuh ha ykun

  //liste fiya 4 screens w kl 3nsor bl lista huwe raem mwk3 bl trtib
  final List<Widget> _screens = const [
    HomeScreen(),
    FavouritesScreen(),
    _PlaceholderScreen(title: 'Appointments'),
    _PlaceholderScreen(title: 'Messages'),
  ];

  @override//chkl screen
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],//ruhi aa liste screen w jibili 3nsor yali raem mwk3u huwe imet current index halae
      bottomNavigationBar: BottomNavigationBar(//aam nkhbr bottom bar enu aya icon lezm tkun mkhtra halae bi nafs imet current index
        currentIndex: _currentIndex,
        onTap: (index) {//lama ef2os aa aya icon tht so flutter byaatinaraema automatically w mnkhznu bi cureent index abr set state
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,//icon mkhtara green w not mkhtara is gray
        unselectedItemColor: AppColors.textSub,
        type: BottomNavigationBarType.fixed,//bikhli icons 4 kla bi nafs size w  sebte
        items: const [//t3rif chkl kl icon ka chkl ady aw chkla lama tkun mkhtra w esm thta
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

//he screen fadye wa2tiye bs chghltu y3rod jmle bi nos screen la had m nbniyon
class _PlaceholderScreen extends StatelessWidget {
  final String title;//yaani kl mara mnstkhdm hed class mn2dr naati esm w huwe by3rdu(fav appoi..)
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$title screen - coming soon'),
    );
  }
}