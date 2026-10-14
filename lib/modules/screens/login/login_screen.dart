import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_images.dart';
import '../../controllers/login/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  LoginScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Top curved gradient banner
            Container(
              height: size.height * 0.32,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE30613),
                    Color(0xFFB0050F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circular shapes
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 40,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  // Header badge
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "CUSTOMER PORTAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content in scrollable view
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Elevated White Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Center(
                              child: Image.asset(
                                AppImages.logo,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Welcome Back",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Sign in to continue to CTS Portal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Form fields
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  // User ID field
                                  TextFormField(
                                    controller: controller.userIdController.value,
                                    cursorColor: AppColors.primaryColor,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Field is required";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      labelText: "User ID",
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 14,
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        color: Color(0xFFE30613),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        color: Color(0xFFE30613),
                                        size: 22,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE30613),
                                          width: 1.8,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: Colors.red.shade400,
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE30613),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Password field
                                  Obx(
                                    () => TextFormField(
                                      controller: controller.passwordController.value,
                                      cursorColor: AppColors.primaryColor,
                                      obscureText: !controller.isShow.value,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        if (formKey.currentState!.validate()) {
                                          controller.login(
                                            body: {
                                              "username": controller.userIdController.value.text.trim(),
                                              "password": controller.passwordController.value.text.trim(),
                                            },
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Field is required";
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        labelText: "Password",
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                        floatingLabelStyle: const TextStyle(
                                          color: Color(0xFFE30613),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: Color(0xFFE30613),
                                          size: 22,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.isShow.value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: const Color(0xFF64748B),
                                            size: 20,
                                          ),
                                          onPressed: () => controller.isShow.value = !controller.isShow.value,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 1.2,
                                        ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                          color: Color(0xFFE30613),
                                          width: 1.8,
                                        ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                          color: Colors.red.shade400,
                                          width: 1.2,
                                        ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                          color: Color(0xFFE30613),
                                          width: 1.8,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Login Button
                            Obx(
                              () => Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: controller.isLoading.value
                                      ? null
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFE30613),
                                            Color(0xFFB0050F),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                  boxShadow: controller.isLoading.value
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(0xFFE30613).withValues(alpha: 0.35),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          if (formKey.currentState!.validate()) {
                                            controller.login(
                                              body: {
                                                "username": controller.userIdController.value.text.trim(),
                                                "password": controller.passwordController.value.text.trim(),
                                              },
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: controller.isLoading.value
                                        ? Colors.grey.shade400
                                        : Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Login",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 19,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Secure Customer Login",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "© Chintamani Transport Services",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
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
