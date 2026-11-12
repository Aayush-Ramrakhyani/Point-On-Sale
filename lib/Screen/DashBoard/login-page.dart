// ignore_for_file: must_be_immutable, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos/Backend/Google-Services.dart';
import 'package:pos/Screen/DashBoard/Forget-Password.dart';
import 'package:pos/Screen/DashBoard/SignUp.dart';
import 'package:pos/Screen/DashBoard/dashboard.dart';
import 'package:pos/Frontend/UX/textField.dart';
import 'package:pos/theme/app_theme.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool signin = false;
  bool showPassword = true;
  final GoogleServicesClass googleServices = GoogleServicesClass();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = username.text.trim();
    final pass = password.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => signin = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      final User? user = userCredential.user;
      if (user != null && mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => MyDashboard(user1: user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please check your credentials.';
      }
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => signin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          // ── Dark gradient header ──────────────────────────────────────────
          Container(
            height: size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
          ),

          // ── Light bottom background ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.6,
              color: AppColors.bgLight,
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Hero logo — shared with splash screen
                  Hero(
                    tag: 'pos_logo',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.point_of_sale_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'POINT OF SALE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // ── Login card ────────────────────────────────────────────
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                          // Heading
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ).animate().fadeIn(delay: 350.ms).slideX(
                                begin: -0.15,
                                end: 0,
                                delay: 350.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 4),

                          Text(
                            'Sign in to your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Email field
                          textField(username, 'Email', 'Email')
                              .animate()
                              .fadeIn(delay: 450.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 450.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 14),

                          // Password field
                          textFieldWithIcon(
                            password,
                            'Password',
                            'Password',
                            showPassword,
                            Icon(showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            () => setState(() => showPassword = !showPassword),
                          )
                              .animate()
                              .fadeIn(delay: 530.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 530.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyForgetPassword(),
                                ),
                              ),
                              child: Text(
                                'Forgot your password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 400.ms),

                          const SizedBox(height: 22),

                          // Login button
                          GradientButton(
                            text: 'Login',
                            isLoading: signin,
                            onPressed: signin ? null : login,
                          )
                              .animate()
                              .fadeIn(delay: 650.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 650.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFE2E8F0))),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFE2E8F0))),
                            ],
                          ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                          const SizedBox(height: 20),

                          // Social login icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(
                                  'assets/logos/fb.jpeg', null, 0, circular: false),
                              const SizedBox(width: 16),
                              _socialButton('assets/logos/twitter.png', null, 1,
                                  circular: true),
                              const SizedBox(width: 16),
                              _socialButton(
                                  'assets/logos/google.png',
                                  () => googleServices.googlesignin(context),
                                  2,
                                  circular: false),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sign up link
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpPage()),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "New user?  ",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Create an account',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.35,
                        end: 0,
                        delay: 300.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(delay: 300.ms, duration: 500.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String asset, VoidCallback? onTap, int index,
      {required bool circular}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFE2E8F0)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: circular
              ? ClipOval(
                  child: Image.asset(asset,
                      width: 30, height: 30, fit: BoxFit.contain))
              : Image.asset(asset, width: 30, height: 30, fit: BoxFit.contain),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (750 + index * 80).ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1.0, 1.0),
          delay: (750 + index * 80).ms,
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}
