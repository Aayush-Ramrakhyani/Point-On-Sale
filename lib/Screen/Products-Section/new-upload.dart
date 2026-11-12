import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyUploadPage extends StatefulWidget {
  const MyUploadPage({super.key});

  @override
  State<MyUploadPage> createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  final TextEditingController url = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  String? useruid;
  bool isLoading = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void dispose() {
    url.dispose();
    name.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() => useruid = user.uid);
    }
  }

  Future<void> _uploadProduct() async {
    final productName = name.text.trim();
    final productPrice = price.text.trim();
    final imageUrl = url.text.trim();

    if (productName.isEmpty) {
      Fluttertoast.showToast(msg: "Product name is required");
      return;
    }
    if (productPrice.isEmpty) {
      Fluttertoast.showToast(msg: "Price is required");
      return;
    }
    if (double.tryParse(productPrice) == null) {
      Fluttertoast.showToast(msg: "Enter a valid price");
      return;
    }
    if (useruid == null) {
      Fluttertoast.showToast(msg: "User not authenticated. Please re-login.");
      return;
    }

    setState(() => isUploading = true);
    try {
      await FirebaseFirestore.instance
          .collection("Products")
          .doc(useruid)
          .collection("Products1")
          .doc()
          .set({
        "Url": imageUrl,
        "Name": productName,
        "Price": productPrice,
      });

      name.clear();
      price.clear();
      url.clear();

      if (mounted) {
        Fluttertoast.showToast(msg: "Product added successfully!");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: Text('"$productName" has been added to your store.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add product. Try again.");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Add New Product",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: name,
              label: "Product Name",
              hint: "e.g. Burger, Pizza",
              icon: Icons.fastfood_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: price,
              label: "Price (₹)",
              hint: "e.g. 150",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: url,
              label: "Image URL (optional)",
              hint: "https://example.com/image.jpg",
              icon: Icons.image_outlined,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            const Text(
              "Leave Image URL empty to use the default product image.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.maxFinite,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isUploading ? null : _uploadProduct,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8E24AA), Color(0xFFFB8C00)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add Product",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8E24AA), width: 2),
        ),
      ),
    );
  }
}
