@@ .. @@
 import 'package:flutter/material.dart';
+import '../core/models/order.dart';
+import '../core/services/api_service.dart';

 class TrackScreen extends StatefulWidget {
@@ .. @@
 }

 class _TrackScreenState extends State<TrackScreen> {
+  List<Order> orders = [];
+  bool isLoading = true;
+
+  @override
+  void initState() {
+    super.initState();
+    _loadOrders();
+  }
+
+  Future<void> _loadOrders() async {
+    setState(() {
+      isLoading = true;
+    });
+
+    try {
+      final loadedOrders = await ApiService.getUserOrders();
+      setState(() {
+        orders = loadedOrders;
+        isLoading = false;
+      });
+    } catch (e) {
+      setState(() {
+        isLoading = false;
+      });
+      ScaffoldMessenger.of(context).showSnackBar(
+        SnackBar(content: Text('Error loading orders: $e')),
+      );
+    }
+  }
+
+  Color _getStatusColor(String status) {
+    switch (status.toLowerCase()) {
+      case 'placed':
+        return Colors.orange;
+      case 'processing':
+        return Colors.blue;
+      case 'completed':
+        return Colors.green;
+      default:
+        return Colors.grey;
+    }
+  }
+
+  IconData _getStatusIcon(String status) {
+    switch (status.toLowerCase()) {
+      case 'placed':
+        return Icons.shopping_cart;
+      case 'processing':
+        return Icons.settings;
+      case 'completed':
+        return Icons.check_circle;
+      default:
+        return Icons.help;
+    }
+  }
+
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Track Orders'),
         backgroundColor: Colors.green,
         foregroundColor: Colors.white,
+        actions: [
+          IconButton(
+            icon: const Icon(Icons.refresh),
+            onPressed: _loadOrders,
+          ),
+        ],
       ),
-      body: const Center(
-        child: Column(
-          mainAxisAlignment: MainAxisAlignment.center,
-          children: [
-            Icon(
-              Icons.local_shipping,
-              size: 100,
-              color: Colors.green,
-            ),
-            SizedBox(height: 20),
-            Text(
-              'Track Your Orders',
-              style: TextStyle(
-                fontSize: 24,
-                fontWeight: FontWeight.bold,
+      body: RefreshIndicator(
+        onRefresh: _loadOrders,
+        child: isLoading
+            ? const Center(child: CircularProgressIndicator())
+            : orders.isEmpty
+                ? const Center(
+                    child: Column(
+                      mainAxisAlignment: MainAxisAlignment.center,
+                      children: [
+                        Icon(
+                          Icons.shopping_cart_outlined,
+                          size: 100,
+                          color: Colors.grey,
+                        ),
+                        SizedBox(height: 20),
+                        Text(
+                          'No Orders Yet',
+                          style: TextStyle(
+                            fontSize: 24,
+                            fontWeight: FontWeight.bold,
+                            color: Colors.grey,
+                          ),
+                        ),
+                        SizedBox(height: 10),
+                        Text(
+                          'Your orders will appear here once you place them',
+                          style: TextStyle(
+                            fontSize: 16,
+                            color: Colors.grey,
+                          ),
+                          textAlign: TextAlign.center,
+                        ),
+                      ],
+                    ),
+                  )
+                : ListView.builder(
+                    padding: const EdgeInsets.all(16.0),
+                    itemCount: orders.length,
+                    itemBuilder: (context, index) {
+                      final order = orders[index];
+                      return Card(
+                        elevation: 4,
+                        margin: const EdgeInsets.only(bottom: 16),
+                        shape: RoundedRectangleBorder(
+                          borderRadius: BorderRadius.circular(12),
+                        ),
+                        child: Padding(
+                          padding: const EdgeInsets.all(16.0),
+                          child: Column(
+                            crossAxisAlignment: CrossAxisAlignment.start,
+                            children: [
+                              Row(
+                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                                children: [
+                                  Text(
+                                    'Order #${order.id}',
+                                    style: const TextStyle(
+                                      fontSize: 18,
+                                      fontWeight: FontWeight.bold,
+                                    ),
+                                  ),
+                                  Container(
+                                    padding: const EdgeInsets.symmetric(
+                                      horizontal: 12,
+                                      vertical: 6,
+                                    ),
+                                    decoration: BoxDecoration(
+                                      color: _getStatusColor(order.status).withOpacity(0.1),
+                                      borderRadius: BorderRadius.circular(20),
+                                      border: Border.all(
+                                        color: _getStatusColor(order.status),
+                                        width: 1,
+                                      ),
+                                    ),
+                                    child: Row(
+                                      mainAxisSize: MainAxisSize.min,
+                                      children: [
+                                        Icon(
+                                          _getStatusIcon(order.status),
+                                          size: 16,
+                                          color: _getStatusColor(order.status),
+                                        ),
+                                        const SizedBox(width: 4),
+                                        Text(
+                                          order.statusDisplayName,
+                                          style: TextStyle(
+                                            color: _getStatusColor(order.status),
+                                            fontWeight: FontWeight.bold,
+                                            fontSize: 12,
+                                          ),
+                                        ),
+                                      ],
+                                    ),
+                                  ),
+                                ],
+                              ),
+                              const SizedBox(height: 12),
+                              Text(
+                                'Order Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
+                                style: const TextStyle(
+                                  color: Colors.grey,
+                                  fontSize: 14,
+                                ),
+                              ),
+                              const SizedBox(height: 8),
+                              Text(
+                                'Total Amount: \$${order.totalAmount.toStringAsFixed(2)}',
+                                style: const TextStyle(
+                                  fontSize: 16,
+                                  fontWeight: FontWeight.bold,
+                                  color: Colors.green,
+                                ),
+                              ),
+                              const SizedBox(height: 12),
+                              const Text(
+                                'Products:',
+                                style: TextStyle(
+                                  fontSize: 16,
+                                  fontWeight: FontWeight.bold,
+                                ),
+                              ),
+                              const SizedBox(height: 8),
+                              ...order.products.map((product) => Padding(
+                                padding: const EdgeInsets.only(bottom: 4),
+                                child: Row(
+                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                                  children: [
+                                    Expanded(
+                                      child: Text(
+                                        '${product.name} (x${product.quantity})',
+                                        style: const TextStyle(fontSize: 14),
+                                      ),
+                                    ),
+                                    Text(
+                                      '\$${product.totalPrice.toStringAsFixed(2)}',
+                                      style: const TextStyle(
+                                        fontSize: 14,
+                                        fontWeight: FontWeight.bold,
+                                      ),
+                                    ),
+                                  ],
+                                ),
+                              )).toList(),
+                            ],
+                          ),
+                        ),
+                      );
+                    },
+                  ),
+      ),
+    );
+  }
+}
+
+class OrderTrackingWidget extends StatelessWidget {
+  final String status;
+
+  const OrderTrackingWidget({Key? key, required this.status}) : super(key: key);
+
+  @override
+  Widget build(BuildContext context) {
+    final steps = ['placed', 'processing', 'completed'];
+    final currentStepIndex = steps.indexOf(status.toLowerCase());
+
+    return Column(
+      children: [
+        Row(
+          children: steps.asMap().entries.map((entry) {
+            final index = entry.key;
+            final step = entry.value;
+            final isActive = index <= currentStepIndex;
+            final isLast = index == steps.length - 1;
+
+            return Expanded(
+              child: Row(
+                children: [
+                  Container(
+                    width: 30,
+                    height: 30,
+                    decoration: BoxDecoration(
+                      shape: BoxShape.circle,
+                      color: isActive ? Colors.green : Colors.grey[300],
+                    ),
+                    child: Icon(
+                      _getStepIcon(step),
+                      color: isActive ? Colors.white : Colors.grey,
+                      size: 16,
+                    ),
+                  ),
+                  if (!isLast)
+                    Expanded(
+                      child: Container(
+                        height: 2,
+                        color: isActive ? Colors.green : Colors.grey[300],
+                      ),
+                    ),
+                ],
               ),
-            ),
-            SizedBox(height: 10),
-            Text(
-              'Coming Soon!',
-              style: TextStyle(
-                fontSize: 16,
-                color: Colors.grey,
+            );
+          }).toList(),
+        ),
+        const SizedBox(height: 8),
+        Row(
+          children: steps.asMap().entries.map((entry) {
+            final index = entry.key;
+            final step = entry.value;
+            final isActive = index <= currentStepIndex;
+
+            return Expanded(
+              child: Text(
+                _getStepLabel(step),
+                textAlign: TextAlign.center,
+                style: TextStyle(
+                  fontSize: 12,
+                  color: isActive ? Colors.green : Colors.grey,
+                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
+                ),
               ),
-            ),
-          ],
+            );
+          }).toList(),
         ),
+      ],
+    );
+  }
+
+  IconData _getStepIcon(String step) {
+    switch (step) {
+      case 'placed':
+        return Icons.shopping_cart;
+      case 'processing':
+        return Icons.settings;
+      case 'completed':
+        return Icons.check;
+      default:
+        return Icons.help;
+    }
+  }
+
+  String _getStepLabel(String step) {
+    switch (step) {
+      case 'placed':
+        return 'Placed';
+      case 'processing':
+        return 'Processing';
+      case 'completed':
+        return 'Completed';
+      default:
+        return step;
+    }
+  }
+}
+