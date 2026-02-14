import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList users = [].obs;
  final RxList orders = [].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadOrders();
  }

  void _loadUsers() {
    _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      users.value = snapshot.docs;
    });
  }

  Future addDailyAmount(int amount) async {
    try {
      for (var user in users) {
        await _firestore.collection('users').doc(user.id).update({
          'balance': FieldValue.increment(amount),
        });

        await _firestore.collection('transactions').add({
          'userId': user.id,
          'amount': amount,
          'type': 'daily_credit',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      Get.snackbar('Success', 'Daily amount added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add daily amount: $e');
    }
  }

  Future assignAmountToUser(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': FieldValue.increment(amount),
      });

      await _firestore.collection('transactions').add({
        'userId': userId,
        'amount': amount,
        'type': 'admin_assignment',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Amount assigned successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign amount: $e');
    }
  }

  Future editUserAmount(String userId, int newAmount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': newAmount, // Now storing as int
      });

      await _firestore.collection('transactions').add({
        'userId': userId,
        'amount': newAmount,
        'type': 'amount_edited',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Amount updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update amount: $e');
    }
  }

  Future markAsPaid(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentBalance = (userDoc.data()?['balance'] ?? 0) as int;

      await _firestore.collection('users').doc(userId).update({
        'balance': 0, // Store as int
      });

      await _firestore.collection('transactions').add({
        'userId': userId,
        'amount': -currentBalance,
        'type': 'payment',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Payment recorded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payment: $e');
    }
  }

  void _loadOrders() {
    _firestore.collection('orders').snapshots().listen((snapshot) {
      orders.value = snapshot.docs;
    });
  }

  Future<void> markOrderAsDone(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'done',
      });
      Get.snackbar('Success', 'Order marked as done');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark order: $e');
    }
  }
}
