@@ .. @@
 import 'package:flutter/material.dart';
+import 'package:awesome_dialog/awesome_dialog.dart';
 import '../core/models/product.dart';
 import '../core/services/api_service.dart';
@@ .. @@
 class _ProductsScreenNewState extends State<ProductsScreenNew> {
   List<Product> products = [];
   bool isLoading = true;
+  int currentPage = 1;
+  int productsPerPage = 10;
+  bool hasMoreProducts = true;
+  final ScrollController _scrollController = ScrollController();
 
   @override
   void initState() {
     super.initState();
-    _loadProducts();
+    _loadProducts(refresh: true);
+    _scrollController.addListener(_onScroll);
+  }
+
+  @override
+  void dispose() {
+    _scrollController.dispose();
+    super.dispose();
+  }
+
+  void _onScroll() {
+    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
+      if (hasMoreProducts && !isLoading) {
+        _loadMoreProducts();
+      }
+    }
   }

-  Future<void> _loadProducts() async {
+  Future<void> _loadProducts({bool refresh = false}) async {
+    if (refresh) {
+      setState(() {
+        currentPage = 1;
+        products.clear();
+        hasMoreProducts = true;
+      });
+    }
+    
     setState(() {
       isLoading = true;
     });

     try {
-      final loadedProducts = await ApiService.getProducts();
+      final loadedProducts = await ApiService.getProducts(
+        limit: productsPerPage,
+        page: currentPage,
+      );
+      
       setState(() {
-        products = loadedProducts;
+        if (refresh) {
+          products = loadedProducts;
+        } else {
+          products.addAll(loadedProducts);
+        }
+        hasMoreProducts = loadedProducts.length == productsPerPage;
         isLoading = false;
       });
     } catch (e) {
       setState(() {
         isLoading = false;
       });
-      ScaffoldMessenger.of(context).showSnackBar(
-        SnackBar(content: Text('Error loading products: $e')),
+      _showErrorDialog('Error loading products: $e');
+    }
+  }
+
+  Future<void> _loadMoreProducts() async {
+    setState(() {
+      currentPage++;
+    });
+    await _loadProducts();
+  }
+
+  void _showErrorDialog(String message) {
+    AwesomeDialog(
+      context: context,
+      dialogType: DialogType.error,
+      animType: AnimType.bottomSlide,
+      title: 'Error',
+      desc: message,
+      btnOkOnPress: () {},
+    ).show();
+  }
+
+  void _showSuccessDialog(String message) {
+    AwesomeDialog(
+      context: context,
+      dialogType: DialogType.success,
+      animType: AnimType.bottomSlide,
+      title: 'Success',
+      desc: message,
+      btnOkOnPress: () {},
+    ).show();
+  }
+
+  Future<void> _addToCart(Product product) async {
+    try {
+      // For now, we'll just place a single item order
+      // In a real app, you'd have a cart system
+      await ApiService.placeOrder([
+        {
+          'id': product.id,
+          'quantity': 1,
+        }
+      ]);
+      
+      _showSuccessDialog('Product "${product.name}" has been ordered successfully!');
+    } catch (e) {
+      _showErrorDialog('Failed to place order: $e');
+    }
+  }
+
+  void _showProductDetails(Product product) {
+    showDialog(
+      context: context,
+      builder: (BuildContext context) {
+        return AlertDialog(
+          title: Text(product.name),
+          content: SingleChildScrollView(
+            child: Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              mainAxisSize: MainAxisSize.min,
+              children: [
+                if (product.fullImageUrl.isNotEmpty)
+                  Container(
+                    height: 200,
+                    width: double.infinity,
+                    decoration: BoxDecoration(
+                      borderRadius: BorderRadius.circular(8),
+                    ),
+                    child: ClipRRect(
+                      borderRadius: BorderRadius.circular(8),
+                      child: Image.network(
+                        product.fullImageUrl,
+                        fit: BoxFit.cover,
+                        errorBuilder: (context, error, stackTrace) {
+                          return Container(
+                            color: Colors.grey[300],
+                            child: const Icon(
+                              Icons.image_not_supported,
+                              size: 50,
+                              color: Colors.grey,
+                            ),
+                          );
+                        },
+                        loadingBuilder: (context, child, loadingProgress) {
+                          if (loadingProgress == null) return child;
+                          return Container(
+                            color: Colors.grey[300],
+                            child: const Center(
+                              child: CircularProgressIndicator(),
+                            ),
+                          );
+                        },
+                      ),
+                    ),
+                  ),
+                const SizedBox(height: 16),
+                Text(
+                  'Price: \$${product.price.toStringAsFixed(2)}',
+                  style: const TextStyle(
+                    fontSize: 18,
+                    fontWeight: FontWeight.bold,
+                    color: Colors.green,
+                  ),
+                ),
+                const SizedBox(height: 8),
+                Text(
+                  'Description:',
+                  style: const TextStyle(
+                    fontSize: 16,
+                    fontWeight: FontWeight.bold,
+                  ),
+                ),
+                const SizedBox(height: 4),
+                Text(
+                  product.description,
+                  style: const TextStyle(fontSize: 14),
+                ),
+              ],
+            ),
+          ),
+          actions: [
+            TextButton(
+              onPressed: () => Navigator.of(context).pop(),
+              child: const Text('Close'),
+            ),
+            ElevatedButton(
+              onPressed: () {
+                Navigator.of(context).pop();
+                _addToCart(product);
+              },
+              style: ElevatedButton.styleFrom(
+                backgroundColor: Colors.green,
+                foregroundColor: Colors.white,
+              ),
+              child: const Text('Order Now'),
+            ),
+          ],
+        );
+      },
     );
   }

@@ .. @@
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Products'),
         backgroundColor: Colors.green,
         foregroundColor: Colors.white,
+        actions: [
+          IconButton(
+            icon: const Icon(Icons.refresh),
+            onPressed: () => _loadProducts(refresh: true),
+          ),
+        ],
       ),
-      body: isLoading
-          ? const Center(child: CircularProgressIndicator())
-          : products.isEmpty
-              ? const Center(child: Text('No products available'))
-              : Padding(
-                  padding: const EdgeInsets.all(16.0),
-                  child: GridView.builder(
-                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
-                      crossAxisCount: 2,
-                      crossAxisSpacing: 16,
-                      mainAxisSpacing: 16,
-                      childAspectRatio: 0.75,
-                    ),
-                    itemCount: products.length,
-                    itemBuilder: (context, index) {
-                      final product = products[index];
-                      return Card(
-                        elevation: 4,
-                        shape: RoundedRectangleBorder(
-                          borderRadius: BorderRadius.circular(12),
-                        ),
-                        child: Column(
-                          crossAxisAlignment: CrossAxisAlignment.start,
-                          children: [
-                            Expanded(
-                              flex: 3,
-                              child: Container(
-                                width: double.infinity,
-                                decoration: const BoxDecoration(
-                                  color: Colors.grey,
-                                  borderRadius: BorderRadius.vertical(
-                                    top: Radius.circular(12),
-                                  ),
-                                ),
-                                child: const Icon(
-                                  Icons.image,
-                                  size: 50,
-                                  color: Colors.white,
-                                ),
+      body: RefreshIndicator(
+        onRefresh: () => _loadProducts(refresh: true),
+        child: isLoading && products.isEmpty
+            ? const Center(child: CircularProgressIndicator())
+            : products.isEmpty
+                ? const Center(child: Text('No products available'))
+                : Padding(
+                    padding: const EdgeInsets.all(16.0),
+                    child: GridView.builder(
+                      controller: _scrollController,
+                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
+                        crossAxisCount: 2,
+                        crossAxisSpacing: 16,
+                        mainAxisSpacing: 16,
+                        childAspectRatio: 0.75,
+                      ),
+                      itemCount: products.length + (hasMoreProducts ? 1 : 0),
+                      itemBuilder: (context, index) {
+                        if (index == products.length) {
+                          return const Center(
+                            child: Padding(
+                              padding: EdgeInsets.all(16.0),
+                              child: CircularProgressIndicator(),
+                            ),
+                          );
+                        }
+                        
+                        final product = products[index];
+                        return GestureDetector(
+                          onTap: () => _showProductDetails(product),
+                          child: Card(
+                            elevation: 4,
+                            shape: RoundedRectangleBorder(
+                              borderRadius: BorderRadius.circular(12),
+                            ),
+                            child: Column(
+                              crossAxisAlignment: CrossAxisAlignment.start,
+                              children: [
+                                Expanded(
+                                  flex: 3,
+                                  child: Container(
+                                    width: double.infinity,
+                                    decoration: const BoxDecoration(
+                                      borderRadius: BorderRadius.vertical(
+                                        top: Radius.circular(12),
+                                      ),
+                                    ),
+                                    child: ClipRRect(
+                                      borderRadius: const BorderRadius.vertical(
+                                        top: Radius.circular(12),
+                                      ),
+                                      child: product.fullImageUrl.isNotEmpty
+                                          ? Image.network(
+                                              product.fullImageUrl,
+                                              fit: BoxFit.cover,
+                                              errorBuilder: (context, error, stackTrace) {
+                                                return Container(
+                                                  color: Colors.grey[300],
+                                                  child: const Icon(
+                                                    Icons.image_not_supported,
+                                                    size: 50,
+                                                    color: Colors.grey,
+                                                  ),
+                                                );
+                                              },
+                                              loadingBuilder: (context, child, loadingProgress) {
+                                                if (loadingProgress == null) return child;
+                                                return Container(
+                                                  color: Colors.grey[300],
+                                                  child: const Center(
+                                                    child: CircularProgressIndicator(),
+                                                  ),
+                                                );
+                                              },
+                                            )
+                                          : Container(
+                                              color: Colors.grey[300],
+                                              child: const Icon(
+                                                Icons.image,
+                                                size: 50,
+                                                color: Colors.grey,
+                                              ),
+                                            ),
+                                    ),
+                                  ),
+                                ),
+                                Expanded(
+                                  flex: 2,
+                                  child: Padding(
+                                    padding: const EdgeInsets.all(8.0),
+                                    child: Column(
+                                      crossAxisAlignment: CrossAxisAlignment.start,
+                                      children: [
+                                        Text(
+                                          product.name,
+                                          style: const TextStyle(
+                                            fontWeight: FontWeight.bold,
+                                            fontSize: 14,
+                                          ),
+                                          maxLines: 2,
+                                          overflow: TextOverflow.ellipsis,
+                                        ),
+                                        const SizedBox(height: 4),
+                                        Text(
+                                          '\$${product.price.toStringAsFixed(2)}',
+                                          style: const TextStyle(
+                                            color: Colors.green,
+                                            fontWeight: FontWeight.bold,
+                                            fontSize: 16,
+                                          ),
+                                        ),
+                                        const Spacer(),
+                                        SizedBox(
+                                          width: double.infinity,
+                                          child: ElevatedButton(
+                                            onPressed: () => _addToCart(product),
+                                            style: ElevatedButton.styleFrom(
+                                              backgroundColor: Colors.green,
+                                              foregroundColor: Colors.white,
+                                              padding: const EdgeInsets.symmetric(vertical: 8),
+                                            ),
+                                            child: const Text(
+                                              'Order',
+                                              style: TextStyle(fontSize: 12),
+                                            ),
+                                          ),
+                                        ),
+                                      ],
+                                    ),
+                                  ),
+                                ),
+                              ],
                               ),
-                            ),
-                            Expanded(
-                              flex: 2,
-                              child: Padding(
-                                padding: const EdgeInsets.all(8.0),
-                                child: Column(
-                                  crossAxisAlignment: CrossAxisAlignment.start,
-                                  children: [
-                                    Text(
-                                      product.name,
-                                      style: const TextStyle(
-                                        fontWeight: FontWeight.bold,
-                                        fontSize: 14,
-                                      ),
-                                      maxLines: 2,
-                                      overflow: TextOverflow.ellipsis,
-                                    ),
-                                    const SizedBox(height: 4),
-                                    Text(
-                                      '\$${product.price.toStringAsFixed(2)}',
-                                      style: const TextStyle(
-                                        color: Colors.green,
-                                        fontWeight: FontWeight.bold,
-                                        fontSize: 16,
-                                      ),
-                                    ),
-                                  ],
-                                ),
-                              ),
-                            ),
-                          ],
-                        ),
-                      );
-                    },
+                            ),
+                          ),
+                        );
+                      },
+                    ),
                   ),
-                ),
+      ),
     );
   }
 }