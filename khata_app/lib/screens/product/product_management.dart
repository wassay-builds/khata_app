import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product/product_controller.dart';

class ProductManagement extends GetView<ProductController> {
  const ProductManagement({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProductController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: Icon(Icons.add),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              title: Text(
                product.name,
                style: TextStyle(
                  color: product.isAvailable ? Colors.black : Colors.red,
                ),
              ),
              subtitle: Text('Rs ${product.price}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: product.isAvailable,
                    onChanged: (value) =>
                        controller.toggleAvailability(product.id, value),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showAddProductDialog(
                      context,
                      productId: product.id,
                      existingName: product.name,
                      existingPrice: product.price,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => controller.deleteProduct(product.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context,
      {String? productId, String? existingName, double? existingPrice}) {
    final nameController = TextEditingController(text: existingName ?? '');
    final priceController =
        TextEditingController(text: existingPrice?.toString() ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(productId == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text(productId == null ? 'Add' : 'Update'),
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (nameController.text.isNotEmpty && price != null) {
                if (productId == null) {
                  controller.addProduct(nameController.text, price);
                } else {
                  controller.editProduct(productId, nameController.text, price);
                }
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter valid details');
              }
            },
          ),
        ],
      ),
    );
  }
}
