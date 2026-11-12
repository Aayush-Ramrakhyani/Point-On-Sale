import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyForgetPassword extends StatefulWidget {
  const MyForgetPassword({super.key});

  @override
  State<MyForgetPassword> createState() => _MyForgetPasswordState();
}

class _MyForgetPasswordState extends State<MyForgetPassword> {
  final TextEditingController username = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    username.dispose();
    super.dispose();
  }

  Future<void> sendResetEmail() async {
    final email = username.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email address");
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text(
            "A password reset link has been sent to your email address. "
            "Please check your inbox.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      username.clear();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email.";
          break;
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;
        default:
          message = "Failed to send reset email. Please try again.";
      }
      Fluttertoast.showToast(msg: message);
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 258,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF8E24AA), Color(0xFFFB8C00)])),
                ),
                Container(
                  height: 473,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(179, 239, 237, 237),
                  ),
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 130),
                  Container(
                    width: 405,
                    margin: const EdgeInsets.all(20),
                    decoration:
                        const BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 28,
                              color: Color(0xFF8E24AA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter your email to receive a reset link",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: username,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "Email address",
                              labelText: "Email",
                              prefixIcon:
                                  Icon(Icons.email_outlined),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                isLoading ? null : sendResetEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ),
                            child: Container(
                              height: 43,
                              width: 315,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8E24AA),
                                        Color(0xFFFB8C00)
                                      ])),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        "Send Reset Link",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight:
                                                FontWeight.w500),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Back to Login",
                              style: TextStyle(
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
