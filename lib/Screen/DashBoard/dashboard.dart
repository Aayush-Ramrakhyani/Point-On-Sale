// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos/Screen/Invoice-Generator/Billing.dart';
import 'package:pos/Screen/MenuDrawer/MenuDrawer.dart';
import 'package:pos/Screen/Products-Section/MyStore.dart';
import 'package:pos/Screen/Products-Section/new-upload.dart';
import 'package:pos/theme/app_theme.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDashboard extends StatefulWidget {
  User? user1;
  MyDashboard({super.key, this.user1});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  // ── Menu items ──────────────────────────────────────────────────────────────
  static const _menuItems = [
    _MenuItem(icon: Icons.storefront_rounded, label: 'My Store', color: Color(0xFF6366F1)),
    _MenuItem(icon: Icons.add_box_rounded, label: 'New Product', color: Color(0xFF10B981)),
    _MenuItem(icon: Icons.receipt_long_rounded, label: 'Generate Bill', color: Color(0xFFF59E0B)),
    _MenuItem(icon: Icons.pie_chart_rounded, label: 'Sales Analysis', color: Color(0xFFEF4444)),
    _MenuItem(icon: Icons.history_rounded, label: 'History', color: Color(0xFF8B5CF6)),
    _MenuItem(icon: Icons.info_outline_rounded, label: 'About Us', color: Color(0xFF06B6D4)),
  ];

  int sales = 0;
  String todaysdate = '';
  String? username;
  int todaysale = 0;
  int todayonlinesales = 0;
  int todayofflinesales = 0;
  int todaycardsales = 0;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    todaysdate = "${today.day}-${today.month}-${today.year}";
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializePrinter());
  }

  Future<void> _loadData() async {
    await Future.wait([fetchUser(), getData(), fetchsales()]);
  }

  Future<void> fetchUser() async {
    if (widget.user1 == null) {
      final current = FirebaseAuth.instance.currentUser;
      if (current == null) return;
      widget.user1 = current;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.user1!.uid)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data();
        if (data != null && data.containsKey("name")) {
          setState(() => username = data["name"]);
        }
      }
    } catch (_) {}
  }

  Future<void> getData() async {
    if (widget.user1 == null) return;
    try {
      final dateKey = "${today.day}-${today.month}-${today.year}";
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection("Receipt")
            .doc(widget.user1!.uid)
            .collection(dateKey)
            .where("Mode of Payment", isEqualTo: "Online")
            .get(),
        FirebaseFirestore.instance
            .collection("Receipt")
            .doc(widget.user1!.uid)
            .collection(dateKey)
            .where("Mode of Payment", isEqualTo: "Cash")
            .get(),
        FirebaseFirestore.instance
            .collection("Receipt")
            .doc(widget.user1!.uid)
            .collection(dateKey)
            .where("Mode of Payment", isEqualTo: "Card")
            .get(),
      ]);

      int online = 0, cash = 0, card = 0;
      for (final d in results[0].docs) { online += (d.data()["Total"] as int? ?? 0); }
      for (final d in results[1].docs) { cash += (d.data()["Total"] as int? ?? 0); }
      for (final d in results[2].docs) { card += (d.data()["Total"] as int? ?? 0); }

      if (mounted) {
        setState(() {
          todayonlinesales = online;
          todayofflinesales = cash;
          todaycardsales = card;
          todaysale = online + cash + card;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchsales() async {
    if (widget.user1 == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Receipt")
          .doc(widget.user1!.uid)
          .collection(todaysdate)
          .get();

      int maxId = 0;
      for (final d in snap.docs) {
        final id = (d.data()["Receipt id"] as int?) ?? 0;
        if (id > maxId) maxId = id;
      }
      if (mounted) setState(() => sales = maxId);
    } catch (_) {}
  }

  Future<void> handleRefresh() async {
    setState(() {
      todaysale = 0;
      todayonlinesales = 0;
      todayofflinesales = 0;
      todaycardsales = 0;
      sales = 0;
    });
    await _loadData();
    await initializePrinter();
  }

  Future<void> initializePrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString('printer_mac') ?? '';
      if (mac.isNotEmpty) {
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      }
    } catch (_) {}
  }

  void _navigateTo(BuildContext context, int index) {
    Widget? page;
    switch (index) {
      case 0: page = const MyStore(); break;
      case 1: page = const MyUploadPage(); break;
      case 2: page = const MyBillgenerator(); break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_menuItems[index].label} coming soon')),
        );
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      drawer: const MyMenuDrawer(),
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        color: AppColors.accent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Gradient header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(size)),

            // ── Stats row ────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatsRow(size)),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Section label ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Menu grid ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMenuCard(context, index),
                  childCount: _menuItems.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username != null ? 'Hello, $username 👋' : 'Dashboard',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _formattedDate(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: handleRefresh,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0, duration: 400.ms),

          const SizedBox(height: 20),

          // Total sale hero card
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: AppColors.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Revenue',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    TweenAnimationBuilder<int>(
                      key: ValueKey(todaysale),
                      tween: IntTween(begin: 0, end: todaysale),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => Text(
                        '₹$v',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Invoices',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    TweenAnimationBuilder<int>(
                      key: ValueKey(sales),
                      tween: IntTween(begin: 0, end: sales),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => Text(
                        '$v',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms),
        ],
      ),
    );
  }

  // ── Payment breakdown row ────────────────────────────────────────────────────
  Widget _buildStatsRow(Size size) {
    final stats = [
      (label: 'Online', value: todayonlinesales, color: const Color(0xFF10B981), icon: Icons.wifi_rounded),
      (label: 'Cash', value: todayofflinesales, color: const Color(0xFFF59E0B), icon: Icons.payments_rounded),
      (label: 'Card', value: todaycardsales, color: const Color(0xFF6366F1), icon: Icons.credit_card_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(s.icon, color: s.color, size: 16),
                      const SizedBox(width: 4),
                      Text(s.label,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<int>(
                    key: ValueKey(s.value),
                    tween: IntTween(begin: 0, end: s.value),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => Text(
                      '₹$v',
                      style: TextStyle(
                        color: s.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (300 + i * 80).ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, delay: (300 + i * 80).ms, duration: 400.ms),
          );
        }),
      ),
    );
  }

  // ── Menu card ────────────────────────────────────────────────────────────────
  Widget _buildMenuCard(BuildContext context, int index) {
    final item = _menuItems[index];
    final images = [
      "my_store.png",
      "new_product.png",
      "bill_generator.png",
      "sales_analysis.png",
      "history.png",
      "Aboutus.png",
    ];

    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/${images[index]}",
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    item.icon,
                    color: item.color,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (500 + index * 70).ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          delay: (500 + index * 70).ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }

  String _formattedDate() {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${today.day} ${months[today.month]} ${today.year}';
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuItem({required this.icon, required this.label, required this.color});
}
