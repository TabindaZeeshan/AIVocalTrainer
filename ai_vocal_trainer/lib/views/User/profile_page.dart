import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel currentUser;
  bool isLoading = false;

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: currentUser),
      ),
    ).then((updatedUser) {
      if (updatedUser != null && mounted) {
        setState(() {
          currentUser = updatedUser;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully!"),
            backgroundColor: softPink,
          ),
        );
      }
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: Text("Logout", style: TextStyle(color: softPink, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: softPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            const Text(
              "Delete Account",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This action is permanent and cannot be undone.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "• All your data will be deleted\n"
              "• All your classes and students will be removed\n"
              "• You will be logged out immediately",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 3,
            ),
            child: const Text("Yes, Delete Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Account deleted successfully"),
              backgroundColor: softPink,
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6D1),
              Color(0xFFFFD6E6),
              Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 72,
                          backgroundColor: lightPinkBg,
                          child: Icon(Icons.person, size: 88, color: softPink),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Username
                      Text(
                        "@${currentUser.username}",
                        style: const TextStyle(fontSize: 18, color: Color(0xFF666666)),
                      ),

                      const SizedBox(height: 50),

                      // Info Cards
                      _buildInfoCard("Full Name", currentUser.name),
                      const SizedBox(height: 16),
                      _buildInfoCard("Email", currentUser.email),
                      const SizedBox(height: 16),
                      _buildInfoCard("Username", "@${currentUser.username}"),

                      const SizedBox(height: 50),

                      // Edit Profile Button
                      GestureDetector(
                        onTap: _navigateToEditProfile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: softPink,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(color: softPink.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),

                      // Logout & Delete Account
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.logout_rounded, color: softPink, size: 28),
                              title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)),
                              onTap: _logout,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 28),
                              title: const Text("Delete Account",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                              onTap: _deleteAccount,
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

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
          ),
        ],
      ),
    );
  }
}

// ====================== EDIT PROFILE PAGE ======================

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late UserModel currentUser;
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  final Color softPink = const Color(0xFFFF6B9D);
  final Color lightPinkBg = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _nameController.text = currentUser.name;
    _usernameController.text = currentUser.username;
    _emailController.text = currentUser.email;
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    try {
      final newName = _nameController.text.trim();
      final newUsername = _usernameController.text.trim();
      final newEmail = _emailController.text.trim();

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) return;

      // 1. Update email in Firebase Auth (if changed)
      if (newEmail != firebaseUser.email) {
        await firebaseUser.verifyBeforeUpdateEmail(newEmail);
      }

      // 2. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'name': newName,
        'username': newUsername,
        'email': newEmail,
      });

      // 3. Create new UserModel with updated values (without copyWith)
      final updatedUser = UserModel(
        name: newName,
        username: newUsername,
        email: newEmail, userId: '', userType: '',
        // IMPORTANT: Add all other fields from your UserModel here
        // For example:
        // uid: currentUser.uid,
        // phone: currentUser.phone,
        // role: currentUser.role,
        // createdAt: currentUser.createdAt,
        // ... copy all other fields from currentUser
      );

      if (mounted) {
        Navigator.pop(context, updatedUser);   // ← This fixes the frontend update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6D1),
              Color(0xFFFFD6E6),
              Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildEditField("Full Name", _nameController),
                      const SizedBox(height: 16),
                      _buildEditField("Username", _usernameController),
                      const SizedBox(height: 16),
                      _buildEditField("Email", _emailController, isEmail: true),

                      const SizedBox(height: 50),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                side: BorderSide(color: softPink),
                              ),
                              child: Text("Cancel", style: TextStyle(color: softPink, fontSize: 17)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: softPink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("Save Changes", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {bool isEmail = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}