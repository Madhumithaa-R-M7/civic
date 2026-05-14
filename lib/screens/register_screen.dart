import 'package:flutter/material.dart';
import 'otp_screen.dart'; // Ensure this path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isMobileSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFD9EFFF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.location_city_rounded,
                    size: 60, color: Color(0xFF2196F3)),
              ),
              const SizedBox(height: 30),
              const Text("Create Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E))),
              const Text("Enter your details to continue",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(13), blurRadius: 15)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection Toggle
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            _buildTab(
                                "Mobile",
                                Icons.phone_android,
                                isMobileSelected,
                                () => setState(() => isMobileSelected = true)),
                            _buildTab(
                                "Email",
                                Icons.email_outlined,
                                !isMobileSelected,
                                () => setState(() => isMobileSelected = false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Full Name Field
                      const Text("Full Name",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your full name",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mobile/Email Field
                      Text(isMobileSelected ? "Mobile Number" : "Email Address",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: isMobileSelected
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: isMobileSelected
                              ? "Enter mobile number"
                              : "Enter email address",
                          prefixIcon: isMobileSelected
                              ? const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text("+91  | ",
                                      style: TextStyle(fontWeight: FontWeight.bold)))
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SEND OTP BUTTON
                      ElevatedButton(
                        onPressed: () {
                          // NAVIGATE TO OTP SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                isFromMobile: isMobileSelected,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2962FF),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text("Send OTP",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 25),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context), // Go back to Login screen
                          child: const Text.rich(TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold))
                              ])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: isActive ? Colors.black : Colors.grey),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: isActive ? Colors.black : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }
}