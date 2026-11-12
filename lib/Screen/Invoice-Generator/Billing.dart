import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/Screen/Invoice-Generator/cart.dart';
import 'package:pos/theme/app_theme.dart';

class MyBillgenerator extends StatefulWidget {
  const MyBillgenerator({super.key});

  @override
  State<MyBillgenerator> createState() => _MyBillgeneratorState();
}

class _MyBillgeneratorState extends State<MyBillgenerator> {
  final TextEditingController foodsearch = TextEditingController();

  List<String> billingitems = [];
  List<int> billingquantity = [];
  List<dynamic> billingprice = [];

  List<String> kotitems = [];
  List<int> kotquantity = [];

  List<String> images = [];
  List<String> items = [];
  List<dynamic> price = [];

  String? useruid;
  String _searchText = '';
  bool nodata = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    foodsearch.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchUser();
    await _fetchProducts();
  }

  Future<void> _fetchUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) setState(() => useruid = user.uid);
  }

  Future<void> _fetchProducts() async {
    if (useruid == null) return;
    try {
      images.clear();
      price.clear();
      items.clear();

      final snap = await FirebaseFirestore.instance
          .collection("Products")
          .doc(useruid)
          .collection("Products1")
          .get();

      if (snap.docs.isNotEmpty) {
        for (final doc in snap.docs) {
          final data = doc.data();
          images.add(data["Url"] ?? "");
          items.add(data["Name"] ?? "");
          price.add(data["Price"] ?? "0");
        }
        if (mounted) setState(() => isLoading = false);
      } else {
        if (mounted) setState(() { nodata = true; isLoading = false; });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: 'Failed to load products');
      }
    }
  }

  void clearCart() {
    kotitems.clear();
    kotquantity.clear();
    billingitems.clear();
    billingquantity.clear();
    billingprice.clear();
  }

  void _addItem(int index) {
    setState(() {
      final itemToFind = items[index];
      if (billingitems.contains(itemToFind)) {
        final idx = billingitems.indexOf(itemToFind);
        billingquantity[idx]++;
        kotquantity[idx]++;
      } else {
        billingitems.add(itemToFind);
        billingquantity.add(1);
        billingprice.add(price[index]);
        kotitems.add(itemToFind);
        kotquantity.add(1);
      }
    });
    Fluttertoast.showToast(msg: "Added to cart");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: TextField(
          controller: foodsearch,
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            border: InputBorder.none,
            suffixIcon: _searchText.isEmpty
                ? Icon(Icons.search, color: AppColors.textSecondary)
                : IconButton(
                    icon: const Icon(Icons.cancel_rounded),
                    onPressed: () {
                      foodsearch.clear();
                      setState(() => _searchText = '');
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _searchText = v.toLowerCase()),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : nodata
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text("No products found",
                          style: TextStyle(
                              fontSize: 18, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() { isLoading = true; nodata = false; });
                          _init();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Refresh"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          setState(() { isLoading = true; nodata = false; });
                          await _init();
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            if (_searchText.isNotEmpty &&
                                !items[index]
                                    .toLowerCase()
                                    .contains(_searchText)) {
                              return const SizedBox.shrink();
                            }
                            return _buildProductCard(index);
                          },
                        ),
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildProductCard(int index) {
    final inCart = billingitems.contains(items[index]);
    return GestureDetector(
      onTap: () => _addItem(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: inCart
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      images[index].isNotEmpty
                          ? images[index]
                          : "https://static.thenounproject.com/png/4693713-200.png",
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgLight,
                        child: Icon(Icons.broken_image,
                            size: 48,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index],
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${price[index]}",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Cart badge
            if (inCart)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '×${billingquantity[billingitems.indexOf(items[index])]}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 350.ms)
        .slideY(
          begin: 0.25,
          end: 0,
          delay: (index * 50).ms,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildBottomBar() {
    final count = billingitems.length;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(clearCart),
              child: const Text("Clear",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (billingitems.isEmpty) {
                    Fluttertoast.showToast(msg: "No items selected");
                    return;
                  }
                  foodsearch.clear();
                  setState(() => _searchText = '');
                  Fluttertoast.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyCartCheckout(
                        itemlist: billingitems,
                        quantitylist: billingquantity,
                        pricelist: billingprice,
                        kotitems: kotitems,
                        kotquantity: kotquantity,
                        clearListCallback: clearCart,
                        useruid: useruid,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        count == 0
                            ? "Checkout"
                            : "Checkout  ($count item${count == 1 ? '' : 's'})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
