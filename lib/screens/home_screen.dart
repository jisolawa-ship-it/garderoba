import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/nav_controller.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import 'account_screen.dart';
import 'add_item_sheet.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'outfits_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _screens = const [
    DashboardScreen(),
    WardrobeScreen(),
    OutfitsScreen(),
    CalendarScreen(),
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
    final nav = context.watch<NavTabController>();

    if (wardrobe.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: nav.index, children: _screens),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.softCardShadow,
                  ),
                  child: Row(
                    children: [
                      _navItem(context, Icons.home_outlined, 'Home', NavTabs.home),
                      _navItem(context, Icons.checkroom_outlined, 'Garderoba', NavTabs.wardrobe),
                      _navItem(context, Icons.style_outlined, 'Stylizacje', NavTabs.outfits),
                      _navItem(
                        context,
                        wardrobe.isSignedIn ? Icons.account_circle : Icons.account_circle_outlined,
                        'Profil',
                        NavTabs.profile,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: _CenterFab(onTap: () => showAddOptionsSheet(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final nav = context.watch<NavTabController>();
    final selected = nav.index == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => context.read<NavTabController>().goTo(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.inkSoft),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: selected ? AppColors.primary : AppColors.inkSoft,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Przycisk "+" na stałe w pasku nawigacji - dostępny z każdego ekranu,
/// otwiera wybór: dodaj ręcznie (jedno ubranie) albo grupowo (kilka zdjęć naraz).
class _CenterFab extends StatefulWidget {
  final VoidCallback onTap;
  const _CenterFab({required this.onTap});

  @override
  State<_CenterFab> createState() => _CenterFabState();
}

class _CenterFabState extends State<_CenterFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
