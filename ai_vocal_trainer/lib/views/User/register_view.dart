import 'package:flutter/material.dart';
import '../../viewmodels/user_viewmodel.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final UserViewModel _viewModel = UserViewModel();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? userType;
  bool isLoading = false;
  String? errorMessage;

  void _clearError() {
    if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }

  Future<void> registerUser() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty || username.isEmpty || email.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty || userType == null) {
      _setErrorAndStopLoading("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _setErrorAndStopLoading("Passwords do not match");
      return;
    }

    if (password.length < 6) {
      _setErrorAndStopLoading("Password must be at least 6 characters");
      return;
    }

    try {
      print("Starting registration for email: $email");

      final result = await _viewModel.registerUser(
        name: name,
        username: username,
        email: email,
        password: password,
        userType: userType!,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => "Registration timed out. Please check your internet connection.",
      );

      if (!mounted) return;

      print("Registration result: $result");

      if (result == "success") {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result);
      }
    } catch (e) {
      print("Registration exception: $e");
      String msg = "Failed to create account. Please try again.";

      if (e.toString().toLowerCase().contains("timeout")) {
        msg = "Request timed out. Check your internet or try again later.";
      } else if (e.toString().toLowerCase().contains("network")) {
        msg = "No internet connection detected.";
      }

      if (mounted) {
        _showErrorDialog(msg);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _setErrorAndStopLoading(String message) {
    if (mounted) {
      setState(() {
        errorMessage = message;
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.25), blurRadius: 30, spreadRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade50),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 90),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text("Account Created Successfully!", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text("Welcome aboard! \nYour account is now ready.", 
                  style: TextStyle(fontSize: 15.5, color: Colors.grey[700], height: 1.4), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1493),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: const Text("Go to Login", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 25, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.shade50),
                child: Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 70),
              ),
              const SizedBox(height: 24),
              const Text("Registration Failed", 
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Text(message, style: TextStyle(fontSize: 15.5, color: Colors.grey[700], height: 1.45), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Try Again", style: TextStyle(color: const Color(0xFFFF1493), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1493),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Go to Home"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9ED4), Color(0xFFFFC1E3), Color(0xFFFFE4EC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/Logo.png', height: 140),
                      const SizedBox(height: 8),
                      const Text(
                        "Precision-Driven Speech Development for Early Learners",
                        style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w500, letterSpacing: 0.4, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                _buildTextField(controller: nameController, label: "Full Name", icon: Icons.person_outline, onChanged: (_) => _clearError()),
                const SizedBox(height: 16),
                _buildTextField(controller: usernameController, label: "Username", icon: Icons.alternate_email, onChanged: (_) => _clearError()),
                const SizedBox(height: 16),
                _buildTextField(controller: emailController, label: "Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, onChanged: (_) => _clearError()),
                const SizedBox(height: 16),
                _buildTextField(controller: passwordController, label: "Password", icon: Icons.lock_outline, obscure: true, onChanged: (_) => _clearError()),
                const SizedBox(height: 16),
                _buildTextField(controller: confirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscure: true, onChanged: (_) => _clearError()),

                const SizedBox(height: 30),

             
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5))],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: userType,
                    hint: const Text("Select Role", style: TextStyle(color: Colors.grey)),
                    decoration: const InputDecoration(border: InputBorder.none),
                    dropdownColor: const Color(0xFFFFF0F5),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    items: const [
                      DropdownMenuItem(value: "Teacher", child: Text("Teacher")),
                      DropdownMenuItem(value: "Parent", child: Text("Parent")),
                      DropdownMenuItem(value: "Admin", child: Text("Administrator")),
                    ],
                    onChanged: (value) {
                      setState(() => userType = value);
                      _clearError();
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 26),
                        const SizedBox(width: 12),
                        Expanded(child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 15.5, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),

                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF1493),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          elevation: 10,
                        ),
                        child: const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF1493)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}