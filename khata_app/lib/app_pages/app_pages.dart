// import 'package:get/get.dart';
// import '../modules/auth/bindings/auth_binding.dart';
// import '../modules/auth/views/login_view.dart';
// import '../modules/admin/bindings/admin_binding.dart';
// import '../modules/admin/views/admin_view.dart';
// import '../modules/user/bindings/user_binding.dart';
// import '../modules/user/views/user_view.dart';

// part 'app_routes.dart';

// class AppPages {
//   static const INITIAL = Routes.LOGIN;

//   static final routes = [
//     GetPage(
//       name: Routes.LOGIN,
//       page: () => LoginView(),
//       binding: AuthBinding(),
//     ),
//     GetPage(
//       name: Routes.ADMIN_DASHBOARD,
//       page: () => AdminView(),
//       binding: AdminBinding(),
//     ),
//     GetPage(
//       name: Routes.USER_DASHBOARD,
//       page: () => UserView(),
//       binding: UserBinding(),
//     ),
//   ];
// }

// // lib/app/routes/app_routes.dart
// part of 'app_pages.dart';

// abstract class Routes {
//   static const LOGIN = '/login';
//   static const ADMIN_DASHBOARD = '/admin-dashboard';
//   static const USER_DASHBOARD = '/user-dashboard';
// }

// // lib/app/data/services/auth_service.dart
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService extends GetxService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Rx<User?> user = Rx<User?>(null);

//   @override
//   void onInit() {
//     user.bindStream(_auth.authStateChanges());
//     super.onInit();
//   }

//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       if (userCredential.user != null) {
//         await _createUserDocument(userCredential.user!);
//       }
//       return userCredential;
//     } catch (e) {
//       print('Error signing in with Google: $e');
//       return null;
//     }
//   }

//   Future<void> _createUserDocument(User user) async {
//     DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
//     DocumentSnapshot doc = await userDoc.get();

//     if (!doc.exists) {
//       await userDoc.set({
//         'email': user.email,
//         'displayName': user.displayName,
//         'photoURL': user.photoURL,
//         'isAdmin': false,
//         'balance': 0,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
