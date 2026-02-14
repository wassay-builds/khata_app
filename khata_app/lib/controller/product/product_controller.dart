import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:khata_app/models/product_models.dart';

class ProductController extends GetxController {
  final products = <ProductModel>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      products.value = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  Future<void> addProduct(String name, double price) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'isAvailable': true, // Default: Available
      });
      await fetchProducts();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    }
  }

  Future<void> editProduct(
      String productId, String newName, double newPrice) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': newName,
        'price': newPrice,
      });
      await fetchProducts();
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    }
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
      });

      // Update locally without disturbing users
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        products[index] = products[index].copyWith(isAvailable: isAvailable);
        products.refresh(); // Refresh UI instantly
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update availability: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      await fetchProducts();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }
}
