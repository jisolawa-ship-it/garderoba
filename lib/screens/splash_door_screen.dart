import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';

/// Ekran pokazywany przy każdym uruchomieniu appki - dwa prawdziwe skrzydła
/// drzwi rozsuwają się na boki, odsłaniając Home, które jest już zbudowane
/// pod spodem. Krótkie, eleganckie powitanie zamiast zwykłego białego
/// ekranu ładowania.
class SplashDoorScreen extends StatefulWidget {
  const SplashDoorScreen({super.key});

  @override
  State<SplashDoorScreen> createState() => _SplashDoorScreenState();
}

class _SplashDoorScreenState extends State<SplashDoorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    // Dłuższa pauza, żeby spokojnie zdążyć zobaczyć logo, zanim drzwi
    // zaczną się otwierać.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Home jest już zbudowane pod spodem - drzwi tylko je odsłaniają.
          const HomeScreen(),
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final p = _progress.value;
              if (p >= 1.0) return const SizedBox.shrink();
              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      left: -size.width / 2 * p,
                      top: 0,
                      bottom: 0,
                      width: size.width / 2,
                      child: _doorPanel(isLeft: true),
                    ),
                    Positioned(
                      right: -size.width / 2 * p,
                      top: 0,
                      bottom: 0,
                      width: size.width / 2,
                      child: _doorPanel(isLeft: false),
                    ),
                    if (p < 0.55)
                      Center(
                        child: Opacity(
                          opacity: (1 - p / 0.55).clamp(0.0, 1.0),
                          child: _logo(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_hanger.png', height: 52),
        const SizedBox(height: 10),
        Text('SZAFNIK', style: displayFont(fontSize: 24, letterSpacing: 4, color: AppColors.ink)),
      ],
    );
  }

  Widget _doorPanel({required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(boxShadow: AppColors.softCardShadow),
      child: Image.asset(
        isLeft ? 'assets/images/door_left.png' : 'assets/images/door_right.png',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
