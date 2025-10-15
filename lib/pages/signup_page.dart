import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'database_helper.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key}); // ❌ Bỏ const ở đây (vì có non-const field)

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // --- Controllers cho form ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final db = DatabaseHelper(); // ✅ đặt đúng chỗ (trong State)

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF9C6BFF);
    final Color lightColor = const Color(0xFFBFA2FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== Header Gradient =====
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mainColor, lightColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/logotodolist.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9C6BFF),
                ),
              ),

              const SizedBox(height: 25),

              // ==== FORM ====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        hint: "Email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          } else if (!value.contains("@")) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _usernameController,
                        icon: Icons.person_outline,
                        hint: "Username",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your username";
                          } else if (value.length < 3) {
                            return "Username must be at least 3 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: "Password",
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _confirmController,
                        icon: Icons.lock_outline,
                        hint: "Confirm password",
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          } else if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildInput(
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        hint: "Phone",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          } else if (value.length < 9) {
                            return "Invalid phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // ==== BUTTON SIGN UP ====
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadowColor: mainColor.withOpacity(0.4),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ==== Chuyển sang trang Sign In ====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color(0xFF9C6BFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==== Hàm xử lý đăng ký ====
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();
      final phone = _phoneController.text.trim();

      final emailExists = await db.emailExists(email);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email đã tồn tại!")),
        );
        return;
      }

      await db.insertUser({
        'email': email,
        'username': username,
        'password': password,
        'phone': phone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo tài khoản thành công!")),
      );

      final user = await db.getUser(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              userId: user['id'],
              email: user['email'],
              username: user['username'],
            ),
          ),
        );
      }
    }
  }

  // ==== Ô nhập liệu ====
  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
