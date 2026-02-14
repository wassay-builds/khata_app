import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_app/auth_services.dart';
import 'package:khata_app/screens/product/product_management.dart';
import '../../controller/auth/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.find<AuthService>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text('Add Daily Amount'),
              onPressed: () => _showAddDailyAmountDialog(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text('Add Products'),
              onPressed: () => Get.to(
                ProductManagement(),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                //
                Text('User Balances',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                //
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: controller.users.length,
                        itemBuilder: (context, index) {
                          final user = controller.users[index];
                          final userData = user.data() as Map<String, dynamic>;
                          // Convert the balance to int
                          final balance = (userData['balance'] ?? 0.0).toInt();

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(userData['email'] ?? ''),
                              subtitle: Text('Balance: Rs $balance'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditAmountDialog(
                                      context,
                                      user.id,
                                      balance,
                                      userData['email'] ?? '',
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.payment,
                                        color: Colors.green),
                                    onPressed: () => _showPaymentConfirmDialog(
                                      context,
                                      user.id,
                                      balance,
                                      userData['email'] ?? '',
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _showAssignAmountDialog(
                                      context,
                                      user.id,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ),
                //
                SizedBox(height: 20),
                //
                Text('Orders',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                //
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.orders.length,
                      itemBuilder: (context, index) {
                        final order = controller.orders[index];
                        final orderData = order.data() as Map<String, dynamic>;

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                                orderData['productName'] ?? 'Unknown Product'),
                            subtitle: Text('Status: ${orderData['status']}'),
                            trailing: orderData['status'] == 'pending'
                                ? ElevatedButton(
                                    onPressed: () =>
                                        controller.markOrderAsDone(order.id),
                                    child: Text('Mark as Done'),
                                  )
                                : Text('Completed',
                                    style: TextStyle(color: Colors.green)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDailyAmountDialog(BuildContext context) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Add Daily Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount != null) {
                controller.addDailyAmount(amount);
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter a valid whole number');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAssignAmountDialog(BuildContext context, String userId) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Assign Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Assign'),
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount != null) {
                controller.assignAmountToUser(userId, amount);
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter a valid whole number');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmDialog(
      BuildContext context, String userId, int balance, String userEmail) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Are you sure you want to mark the following balance as paid?'),
            SizedBox(height: 16),
            Text('User: $userEmail',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Amount: Rs $balance',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text('Mark as Paid'),
            onPressed: () {
              controller.markAsPaid(userId);
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showEditAmountDialog(BuildContext context, String userId,
      int currentBalance, String userEmail) {
    final amountController =
        TextEditingController(text: currentBalance.toString());

    Get.dialog(
      AlertDialog(
        title: Text('Edit Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: $userEmail',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Balance (Rs)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: Text('Update'),
            onPressed: () {
              final newAmount = int.tryParse(amountController.text);
              if (newAmount != null) {
                controller.editUserAmount(userId, newAmount);
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter a valid whole number');
              }
            },
          ),
        ],
      ),
    );
  }
}
