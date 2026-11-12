import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/Frontend/UX/textField.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  File? _pic;
  bool isUploading = false;

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    try {
      final image =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() => _pic = File(image.path));
    } on PlatformException {
      Fluttertoast.showToast(msg: "Camera access denied");
    }
  }

  Future<void> uploadFile() async {
    final productName = nameController.text.trim();
    final productPrice = priceController.text.trim();

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

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "User not authenticated");
      return;
    }

    setState(() => isUploading = true);
    try {
      String downloadUrl = "";

      if (_pic != null) {
        final fileName =
            "${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final ref = FirebaseStorage.instance
            .ref()
            .child("products/${user.uid}/$fileName");
        await ref.putFile(_pic!);
        downloadUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection("Products")
          .doc(user.uid)
          .collection("Products1")
          .doc()
          .set({
        "Url": downloadUrl,
        "Name": productName,
        "Price": productPrice,
      });

      nameController.clear();
      priceController.clear();
      if (mounted) setState(() => _pic = null);

      Fluttertoast.showToast(msg: "Product added successfully!");
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
          msg: e.message ?? "Upload failed. Try again.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed. Try again.");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Product (Camera)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        color: Colors.orange,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: selectImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  height: 200,
                  width: 200,
                  clipBehavior: Clip.antiAlias,
                  child: _pic != null
                      ? Image.file(_pic!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/logos/upload.jpeg",
                              fit: BoxFit.contain,
                              height: 100,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tap to take photo",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: textField(nameController, "Product Name", "Product Name"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: textField(priceController, "Price (₹)", "Price (₹)"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.maxFinite,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isUploading ? null : uploadFile,
                  child: isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.orange)
                      : const Text(
                          "Upload Product",
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
