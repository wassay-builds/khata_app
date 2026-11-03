import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_app/auth_services.dart';
import 'package:khata_app/screens/user/user_view.dart';

import '../../screens/admin/admin_view.dart';

class AuthController extends GetxController {
  // Get.put<AuthService>(AuthService());
  //   Get.put<AuthController>(AuthController());
  final AuthService _authService = Get.put(AuthService());
  final RxBool isLoading = false.obs;

  Future<void> handleSignIn() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Create or update user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'isAdmin': userCredential.user!.email == 'admin.wassay@3.com',
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Check if user is admin
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        final isAdmin = userDoc.data()?['isAdmin'] ?? false;
        isAdmin ? Get.to(() => AdminView()) : Get.to(() => UserView());
        debugPrint("User Email ${userCredential.user!.email}");
      } else {
        Get.snackbar('Error', 'Sign in cancelled');
      }
    } catch (e) {
      Get.snackbar('Error', 'Sign in failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
