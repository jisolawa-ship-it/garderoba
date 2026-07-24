import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import 'account_screen.dart';
import 'outfits_screen.dart';
import 'summary_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    WardrobeScreen(),
    OutfitsScreen(),
    SummaryScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();

    if (wardrobe.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.wine)),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.paper,
        selectedItemColor: AppColors.wine,
        unselectedItemColor: AppColors.inkSoft,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.checkroom_outlined), label: 'Szafa'),
          const BottomNavigationBarItem(icon: Icon(Icons.style_outlined), label: 'Stylizacje'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Podsumowanie'),
          BottomNavigationBarItem(
            icon: Icon(wardrobe.isSignedIn ? Icons.account_circle : Icons.account_circle_outlined),
            label: 'Konto',
          ),
        ],
      ),
    );
  }
}
