import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos/Screen/DashBoard/login-page.dart';
import 'package:pos/Screen/DashBoard/dashboard.dart';
import 'package:pos/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            user != null ? MyDashboard(user1: user) : const loginPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Pulsing glow circle ─────────────────────────────────────────
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) {
                final scale = 1.0 + _glowController.value * 0.25;
                final opacity = 0.08 + _glowController.value * 0.1;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size.width * 0.72,
                    height: size.width * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: opacity),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Second slower ring ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) {
                final scale = 1.0 + (1 - _glowController.value) * 0.3;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size.width * 0.55,
                    height: size.width * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(
                            alpha: 0.15 + _glowController.value * 0.1),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Centre content ──────────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with Hero tag for transition to login
                Hero(
                  tag: 'pos_logo',
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      delay: 300.ms,
                      duration: 900.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 28),

                // App name
                const Text(
                  'POINT OF SALE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      delay: 1000.ms,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(delay: 1000.ms, duration: 600.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Smart Sales · Fast Checkout',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 600.ms),

                const SizedBox(height: 56),

                // Loading indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1800.ms, duration: 500.ms),
              ],
            ),

            // ── Bottom version text ─────────────────────────────────────────
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 2000.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
