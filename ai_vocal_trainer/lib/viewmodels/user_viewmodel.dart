import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/user_model.dart';
import '../core/models/teacher_model.dart';
import '../core/models/parent_model.dart';
import '../core/models/admin_model.dart';

class UserViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  

  Future<String> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      if (name.isEmpty || username.isEmpty || email.isEmpty || 
          password.isEmpty || userType.isEmpty) {
        return "Please fill all fields";
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return "Invalid email format";
      }
      if (password.length < 6) return "Password must be at least 6 characters";

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      dynamic userModel;

      if (userType == 'Teacher') {
        userModel = TeacherModel(
          userId: uid,
          name: name,
          username: username,
          email: email,
          gradeLevel: 'Kindergarten',
          gradeName: '',                   
        );
      } else if (userType == 'Parent') {
        userModel = ParentModel(
          userId: uid,
          name: name,
          username: username,
          email: email,
        );
      } else if (userType == 'Admin') {
        userModel = AdminModel(
          userId: uid,
          name: name,
          username: username,
          email: email,
        );
      } else {
        userModel = UserModel(
          userId: uid,
          name: name,
          username: username,
          email: email,
          userType: userType,
        );
      }

      await _db.collection('users').doc(uid).set(
        userModel.toMap(),
        SetOptions(merge: true),
      );

      return "success";

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Email already in use";
      if (e.code == 'weak-password') return "Weak password";
      if (e.code == 'invalid-email') return "Invalid email";
      return e.message ?? "Authentication failed";
    } catch (e) {
      return "Failed to create account. Please try again.";
    }
  }

  
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please enter email and password";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': return "No account found with this email. Please register first.";
        case 'wrong-password': return "Incorrect password. Please try again.";
        case 'invalid-email': return "Please enter a valid email address.";
        case 'invalid-credential': return "Invalid email or password.";
        case 'user-disabled': return "This account has been disabled.";
        default: return e.message ?? "Login failed.";
      }
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  Future<dynamic> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final userType = data['userType'] as String?;

      switch (userType) {
        case 'Teacher':
          return TeacherModel.fromMap(data);
        case 'Parent':
          return ParentModel.fromMap(data);
        case 'Admin':
          return AdminModel.fromMap(data);
        default:
          return UserModel.fromMap(data);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateTeacherGradeName(String userId, String gradeName) async {
    try {
      await _db.collection('users').doc(userId).update({
        'gradeName': gradeName,
      });
    } catch (e) {
      print("Error updating gradeName: $e");
      rethrow;
    }
  }
Future<bool> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return false;
    } catch (e) {
      print("Forgot password error: $e");
      return false;
    }
  }
}