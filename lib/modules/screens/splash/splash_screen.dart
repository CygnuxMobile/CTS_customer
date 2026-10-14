import 'package:cts_customer/configs/app_colors.dart';
import 'package:cts_customer/configs/app_images.dart';
import 'package:cts_customer/modules/widgets/flutter_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _bottomFade;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Continuous subtle breathing pulse controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Logo entrance: smooth scale + bounce
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Logo fade-in
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Subtitle & badge slide up
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle & badge fade-in
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeIn),
      ),
    );

    // Bottom loading indicator and version info fade-in
    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Breathing pulse for background aura
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _copyFcmToken() async {
    debugPrint("Long press detected on Splash Logo");
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Clipboard.setData(ClipboardData(text: token));
        toastMessage(text: "FCM Token Copied!", color: Colors.green);
        debugPrint("FCM Token: $token");
      } else {
        toastMessage(text: "Could not get FCM Token", color: Colors.red);
      }
    } catch (e) {
      debugPrint("FCM Token Error: $e");
      toastMessage(text: "Error: $e", color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFAFAFC),
                  Color(0xFFFFF7F7),
                ],
              ),
            ),
          ),

          // Decorative Top Right Blurred Accent
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.10),
                    AppColors.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Decorative Bottom Left Blurred Accent
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.07),
                    AppColors.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Decorative subtle geometric ring
          Positioned(
            top: size.height * 0.12,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.05),
                  width: 2,
                ),
              ),
            ),
          ),

          // Main Center Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),

                  // Center Logo and Branding Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Breathing glow & Logo card
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: _copyFcmToken,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _logoFade,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.09,
                                      ),
                                      blurRadius: 36,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Image.asset(
                                  AppImages.logo,
                                  width: size.width * 0.60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Animated Tagline & Badge
                      SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            children: [
                              // Customer Portal Pill Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.20,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "CUSTOMER PORTAL",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Tagline Text
                              Text(
                                "Fast • Reliable • Seamless Logistics",
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Loader & Version Info
                  FadeTransition(
                    opacity: _bottomFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sleek Linear Progress Bar
                          SizedBox(
                            width: 52,
                            height: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                backgroundColor: AppColors.primaryColor
                                    .withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // App Name & Version
                          Text(
                            "Chintamani Transport Services",
                            style: TextStyle(
                              color: const Color(0xFF374151),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "v1.0.8",
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
