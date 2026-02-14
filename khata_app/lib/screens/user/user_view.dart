import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/user_controller.dart';
import 'user_orders_page.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Khata'),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => controller.showCart(),
            ),
            IconButton(
              icon: Icon(Icons.receipt_long),
              onPressed: () => Get.to(() => UserOrdersPage()),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Cart'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductsTab(),
            _buildCartTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Balance Card
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Remaining Balance',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => Text(
                      'Rs.${controller.balance.value}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: controller.balance.value >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
              ],
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No products available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                final data = product.data() as Map<String, dynamic>;
                final isAvailable = data['isAvailable'] ?? false;
                final productId = product.id;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rs.${data['price'] ?? 0}',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (isAvailable) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () =>
                                        controller.decrementQuantity(productId),
                                  ),
                                  Obx(() => Text(
                                        '${controller.getQuantity(productId)}',
                                        style: TextStyle(fontSize: 16),
                                      )),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () =>
                                        controller.incrementQuantity(productId),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    controller.addToCart(productId, data),
                                child: Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 36),
                                ),
                              ),
                            ] else
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Not Available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('Rs.${item.price} x ${item.quantity}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => controller.removeFromCart(item.id),
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs.${controller.cartTotal}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.placeOrder(),
                    child: Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
