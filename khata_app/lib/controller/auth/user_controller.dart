import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final RxDouble balance = 0.0.obs;
  final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;
  final RxMap<String, int> quantities = <String, int>{}.obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxList<DocumentSnapshot> orders = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadProducts();
    _loadOrders();
  }

  void _loadOrders() {
    _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      orders.value = snapshot.docs;
    });
  }

  void _loadUserData() {
    _firestore.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.data()?['balance'] != null) {
        balance.value = (snapshot.data()?['balance'] as num).toDouble();
      }
    });
  }

  void _loadProducts() {
    _firestore
        .collection('products')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      products.value = snapshot.docs;
    });
  }

  int getQuantity(String productId) {
    return quantities[productId] ?? 0;
  }

  void incrementQuantity(String productId) {
    quantities[productId] = (quantities[productId] ?? 0) + 1;
    quantities.refresh();
  }

  void decrementQuantity(String productId) {
    if ((quantities[productId] ?? 0) > 0) {
      quantities[productId] = quantities[productId]! - 1;
      quantities.refresh();
    }
  }

  void addToCart(String productId, Map<String, dynamic> productData) {
    final quantity = quantities[productId] ?? 0;
    if (quantity <= 0) {
      Get.snackbar('Error', 'Please select quantity');
      return;
    }

    final existingItemIndex =
        cartItems.indexWhere((item) => item.id == productId);
    if (existingItemIndex != -1) {
      cartItems.removeAt(existingItemIndex);
    }

    cartItems.add(CartItem(
      id: productId,
      name: productData['name'] ?? '',
      price: (productData['price'] ?? 0).toDouble(),
      quantity: quantity,
    ));

    quantities[productId] = 0;
    quantities.refresh();
    Get.snackbar('Success', 'Added to cart');
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.id == productId);
    Get.snackbar('Success', 'Removed from cart');
  }

  double get cartTotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> placeOrder() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    try {
      final orderTotal = cartTotal;
      if (orderTotal > balance.value) {
        Get.snackbar('Error', 'Insufficient balance');
        return;
      }

      final orderData = {
        'userId': userId,
        'items': cartItems
            .map((item) => {
                  'productId': item.id,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'total': orderTotal,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('orders').add(orderData);
      await _firestore.collection('users').doc(userId).update({
        'balance': FieldValue.increment(-orderTotal),
      });

      cartItems.clear();
      Get.snackbar('Success', 'Order placed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order');
    }
  }

  void showCart() {
    DefaultTabController.of(Get.context!).animateTo(1);
  }
}
