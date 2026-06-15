import 'package:cts_customer/modules/controllers/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../configs/app_images.dart';

class LoginScreen extends GetView<LoginController> {
  LoginScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image
              SizedBox(height: 120, child: Image.asset(AppImages.logo, fit: BoxFit.contain)),
              const SizedBox(height: 24),
              const Text("Log in to continue", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),
              // User ID field
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (v) {
                        if (v!.trim().isEmpty) {
                          return "Field is required";
                        }
                        return null;
                      },
                      controller: controller.userIdController.value,
                      cursorColor: Color(0xFFE30613),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline, color: Colors.black87),
                        labelText: "User ID",
                        labelStyle: const TextStyle(color: Colors.black87),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFE30613), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black54, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black54, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    Obx(
                      () => TextFormField(
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "Field is required";
                          }
                          return null;
                        },
                        controller: controller.passwordController.value,
                        cursorColor: Color(0xFFE30613),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.black87),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFE30613), width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black54, width: 1),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black54, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isShow.value ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => controller.isShow.value = !controller.isShow.value,
                          ),
                        ),
                        obscureText: !controller.isShow.value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Obx(
                () => ElevatedButton(
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
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
