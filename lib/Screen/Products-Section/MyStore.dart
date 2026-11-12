import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/theme/app_theme.dart';

class MyStore extends StatefulWidget {
  const MyStore({super.key});

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  List<String> images = [];
  List<String> items = [];
  List<dynamic> price = [];
  String? useruid;
  bool isLoading = true;
  bool nodata = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchUser();
    await _fetchProducts();
  }

  Future<void> _fetchUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() => useruid = user.uid);
    }
  }

  Future<void> _fetchProducts() async {
    if (useruid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Products")
          .doc(useruid)
          .collection("Products1")
          .get();

      if (snap.docs.isNotEmpty) {
        final newImages = <String>[];
        final newItems = <String>[];
        final newPrice = <dynamic>[];
        for (final doc in snap.docs) {
          final data = doc.data();
          newImages.add(data["Url"] ?? "");
          newItems.add(data["Name"] ?? "");
          newPrice.add(data["Price"] ?? "0");
        }
        if (mounted) {
          setState(() {
            images = newImages;
            items = newItems;
            price = newPrice;
            isLoading = false;
          });
        }
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

  Future<void> _deleteProduct(int index) async {
    if (useruid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Products")
          .doc(useruid)
          .collection("Products1")
          .where("Name", isEqualTo: items[index])
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }

      setState(() {
        images.removeAt(index);
        items.removeAt(index);
        price.removeAt(index);
        if (items.isEmpty) nodata = true;
      });
      Fluttertoast.showToast(msg: "Product deleted");
    } catch (_) {
      Fluttertoast.showToast(msg: "Failed to delete product");
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Product",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete "${items[index]}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProduct(index);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('My Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() { isLoading = true; nodata = false; });
              _init();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() { isLoading = true; nodata = false; });
          await _init();
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : nodata
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 80,
                            color: AppColors.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text("No products yet",
                            style: TextStyle(
                                fontSize: 18, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text("Add products using 'New Product'",
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildCard(index),
                  ),
      ),
    );
  }

  Widget _buildCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: AppColors.textSecondary.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
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
                GestureDetector(
                  onTap: () => _confirmDelete(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 400.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: (index * 60).ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}
