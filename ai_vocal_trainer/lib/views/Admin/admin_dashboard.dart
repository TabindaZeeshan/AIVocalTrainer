import 'package:flutter/material.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../core/models/admin_model.dart';
import '../User/profile_page.dart';
import 'admin_student_progress_page.dart';   // ← New Import

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserViewModel _viewModel = UserViewModel();
  AdminModel? admin;
  bool isLoading = true;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final data = await _viewModel.getCurrentUserData();
    if (data is AdminModel) {
      setState(() => admin = data);
    }
    setState(() => isLoading = false);
  }

  void _navigateToProfile() {
    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile is still loading...")),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(user: admin!)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB6D1), Color(0xFFFFD6E6), Color(0xFFFFF0F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95))),
                      Text(admin?.name.split(" ").first ?? "Admin", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 40),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: lightPinkBg, borderRadius: BorderRadius.circular(18)),
                                  child: Icon(Icons.admin_panel_settings_rounded, size: 36, color: softPink),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(child: Text("Admin Controls", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 32),

                            _buildAdminButton(
                              icon: Icons.trending_up_rounded,
                              title: "View Student Progress",
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStudentProgressPage()));
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildAdminButton(
                              icon: Icons.timeline_rounded,
                              title: "View Application Usage",
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon"))),
                            ),

                            const SizedBox(height: 12),

                            _buildAdminButton(
                              icon: Icons.analytics_rounded,
                              title: "View Application Metrics",
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon"))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: lightPinkBg, shape: BoxShape.circle),
              child: Icon(icon, color: softPink, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            Icon(Icons.arrow_forward_ios_rounded, color: softPink, size: 20),
          ],
        ),
      ),
    );
  }
}