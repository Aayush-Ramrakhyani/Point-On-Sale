import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos/Screen/DashBoard/login-page.dart';
import 'package:pos/Screen/Invoice-Generator/Billing.dart';
import 'package:pos/Screen/Products-Section/MyStore.dart';
import 'package:pos/Screen/Products-Section/New-Items.dart';
import 'package:pos/Screen/Products-Section/new-upload.dart';
import 'package:pos/Screen/Receipts/receipts.dart';
import 'package:pos/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMenuDrawer extends StatefulWidget {
  const MyMenuDrawer({super.key});

  @override
  State<MyMenuDrawer> createState() => _MyMenuDrawerState();
}

class _MyMenuDrawerState extends State<MyMenuDrawer> {
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userEmail = user.email;
      _userName = user.displayName ?? user.email?.split('@').first;
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const loginPage()),
      (route) => false,
    );
  }

  Future<void> _showPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMac = prefs.getString('printer_mac') ?? '';
    final controller = TextEditingController(text: currentMac);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.print_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("Printer Settings",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bluetooth MAC address of your thermal printer:",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "MAC Address",
                hintText: "e.g. DC:0D:30:63:DD:1D",
                prefixIcon: Icon(Icons.bluetooth_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          GradientButton(
            text: "Save",
            height: 40,
            width: 100,
            onPressed: () async {
              await prefs.setString('printer_mac', controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(content: Text("Printer MAC address saved")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.headerDark,
      child: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Container(
            width: double.maxFinite,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (_userName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 12),

                Text(
                  _userName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideX(
                      begin: -0.2,
                      end: 0,
                      delay: 150.ms,
                      duration: 400.ms,
                    ),

                if (_userEmail != null)
                  Text(
                    _userEmail!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ).animate().fadeIn(delay: 220.ms, duration: 400.ms),
              ],
            ),
          ),

          // ── Menu items ───────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item(
                  icon: Icons.storefront_rounded,
                  label: "My Store",
                  color: const Color(0xFF6366F1),
                  delay: 0,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyStore()));
                  },
                ),
                _item(
                  icon: Icons.add_box_rounded,
                  label: "Add Product (URL)",
                  color: const Color(0xFF10B981),
                  delay: 50,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyUploadPage()));
                  },
                ),
                _item(
                  icon: Icons.camera_alt_rounded,
                  label: "Add Product (Camera)",
                  color: const Color(0xFFF59E0B),
                  delay: 100,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NewProductScreen()));
                  },
                ),
                _item(
                  icon: Icons.receipt_long_rounded,
                  label: "Generate Bill",
                  color: const Color(0xFF8E24AA),
                  delay: 150,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyBillgenerator()));
                  },
                ),
                _item(
                  icon: Icons.history_rounded,
                  label: "View Receipts",
                  color: const Color(0xFF06B6D4),
                  delay: 200,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReceiptsPage()));
                  },
                ),
                _item(
                  icon: Icons.print_rounded,
                  label: "Printer Settings",
                  color: const Color(0xFF64748B),
                  delay: 250,
                  onTap: () => _showPrinterSettings(),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Divider(
                      color: Colors.white.withValues(alpha: 0.1), height: 1),
                ),

                _item(
                  icon: Icons.logout_rounded,
                  label: "Log Out",
                  color: const Color(0xFFEF4444),
                  delay: 300,
                  onTap: _logout,
                ),
              ],
            ),
          ),

          // ── Version footer ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              "v1.0.0  ·  Point of Sale",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.white.withValues(alpha: 0.3), size: 18),
    )
        .animate()
        .fadeIn(delay: (300 + delay).ms, duration: 350.ms)
        .slideX(
          begin: -0.1,
          end: 0,
          delay: (300 + delay).ms,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}
