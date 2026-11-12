import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController cpassword = TextEditingController();
  final TextEditingController name = TextEditingController();
  bool isLoading = false;
  bool showPassword = true;
  bool showConfirmPassword = true;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    cpassword.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final email = username.text.trim();
    final pass = password.text;
    final confirmPass = cpassword.text;
    final fullName = name.text.trim();

    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty || fullName.isEmpty) {
      Fluttertoast.showToast(msg: "All fields are required");
      return;
    }

    if (pass != confirmPass) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    if (pass.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
      return;
    }

    setState(() => isLoading = true);

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .set({"name": fullName});
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/gifs/done.gif",
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const Center(
                child: Text(
                  "Registered Successfully!",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            GradientButton(
              text: "Go to Login",
              height: 44,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      Fluttertoast.showToast(msg: message);
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    int delay = 0,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: delay.ms, duration: 400.ms, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          // Header gradient
          Container(
            height: size.height * 0.35,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: size.height * 0.68, color: AppColors.bgLight),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 28),

                  // Header icon + title
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 34),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 10),

                  const Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Form card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 30,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideX(
                                begin: -0.15,
                                end: 0,
                                delay: 300.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          Text(
                            'Fill in your details to get started',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                          const SizedBox(height: 22),

                          _buildField(
                            controller: name,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            delay: 400,
                          ),

                          const SizedBox(height: 14),

                          _buildField(
                            controller: username,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            delay: 480,
                          ),

                          const SizedBox(height: 14),

                          _buildField(
                            controller: password,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: showPassword,
                            delay: 560,
                            suffix: IconButton(
                              icon: Icon(showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                  color: AppColors.textSecondary),
                              onPressed: () =>
                                  setState(() => showPassword = !showPassword),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildField(
                            controller: cpassword,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscure: showConfirmPassword,
                            delay: 640,
                            suffix: IconButton(
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() =>
                                  showConfirmPassword = !showConfirmPassword),
                            ),
                          ),

                          const SizedBox(height: 26),

                          GradientButton(
                            text: 'Create Account',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : registerUser,
                            icon: Icons.arrow_forward_rounded,
                          )
                              .animate()
                              .fadeIn(delay: 700.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 700.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 20),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account?  ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 760.ms, duration: 400.ms),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 250.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(delay: 250.ms, duration: 500.ms),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
