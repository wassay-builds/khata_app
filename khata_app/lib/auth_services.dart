import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:khata_app/screens/admin/admin_view.dart';
import 'package:khata_app/screens/user/user_view.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    user.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn().catchError((error) {
        debugPrint('Google Sign In Error: $error');
        Get.back(); // Close loading dialog
        throw error;
      });

      if (googleUser == null) {
        Get.back(); // Close loading dialog
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _auth.signInWithCredential(credential).catchError((error) {
        debugPrint('Firebase Sign In Error: $error');
        Get.back(); // Close loading dialog
        throw error;
      });

      // Create/update user document
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
      }

      Get.back(); // Close loading dialog
      return userCredential;
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      // Close loading dialog if still showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      rethrow;
    }
  }

  Future<void> _createUserDocument(User user) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot doc = await userDoc.get();

      if (!doc.exists) {
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'isAdmin': false,
          'balance': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw e;
    }
  }
}

// 3. Update your AuthController:
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  Future<void> handleSignIn() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Check if user is admin
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        final isAdmin = userDoc.data()?['isAdmin'] ?? false;

        isAdmin ? Get.to(() => AdminView()) : Get.to(() => UserView());
      } else {
        Get.snackbar(
          'Sign In Cancelled',
          'Please try again',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sign in failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
