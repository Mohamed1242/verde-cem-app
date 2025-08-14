@@ .. @@
 import 'package:flutter/material.dart';
+import '../core/models/user.dart';
+import '../core/services/api_service.dart';
 import 'login_screen.dart';

 class AppDrawer extends StatefulWidget {
@@ .. @@
 }

 class _AppDrawerState extends State<AppDrawer> {
+  User? currentUser;
+  bool isLoading = true;
+
+  @override
+  void initState() {
+    super.initState();
+    _loadCurrentUser();
+  }
+
+  Future<void> _loadCurrentUser() async {
+    try {
+      final user = await ApiService.getCurrentUser();
+      setState(() {
+        currentUser = user;
+        isLoading = false;
+      });
+    } catch (e) {
+      setState(() {
+        isLoading = false;
+      });
+    }
+  }
+
+  Future<void> _logout() async {
+    try {
+      await ApiService.logout();
+      if (mounted) {
+        Navigator.of(context).pushAndRemoveUntil(
+          MaterialPageRoute(builder: (context) => const LoginScreen()),
+          (route) => false,
+        );
+      }
+    } catch (e) {
+      ScaffoldMessenger.of(context).showSnackBar(
+        SnackBar(content: Text('Error logging out: $e')),
+      );
+    }
+  }
+
   @override
   Widget build(BuildContext context) {
     return Drawer(
       child: ListView(
         padding: EdgeInsets.zero,
         children: [
-          const DrawerHeader(
+          DrawerHeader(
             decoration: BoxDecoration(
-              color: Colors.green,
+              color: Colors.green,
             ),
-            child: Text(
-              'Verde Cem',
-              style: TextStyle(
-                color: Colors.white,
-                fontSize: 24,
-                fontWeight: FontWeight.bold,
+            child: isLoading
+                ? const Center(
+                    child: CircularProgressIndicator(
+                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
+                    ),
+                  )
+                : Column(
+                    crossAxisAlignment: CrossAxisAlignment.start,
+                    children: [
+                      const Text(
+                        'Verde Cem',
+                        style: TextStyle(
+                          color: Colors.white,
+                          fontSize: 24,
+                          fontWeight: FontWeight.bold,
+                        ),
+                      ),
+                      const SizedBox(height: 16),
+                      if (currentUser != null) ...[
+                        Text(
+                          currentUser!.name,
+                          style: const TextStyle(
+                            color: Colors.white,
+                            fontSize: 16,
+                            fontWeight: FontWeight.w500,
+                          ),
+                        ),
+                        const SizedBox(height: 4),
+                        Text(
+                          currentUser!.email,
+                          style: const TextStyle(
+                            color: Colors.white70,
+                            fontSize: 14,
+                          ),
+                        ),
+                        if (currentUser!.companyName.isNotEmpty) ...[
+                          const SizedBox(height: 4),
+                          Text(
+                            currentUser!.companyName,
+                            style: const TextStyle(
+                              color: Colors.white70,
+                              fontSize: 12,
+                            ),
+                          ),
+                        ],
+                      ],
+                    ],
+                  ),
+          ),
+          if (currentUser != null) ...[
+            ListTile(
+              leading: const Icon(Icons.person),
+              title: const Text('Profile'),
+              subtitle: Text(currentUser!.name),
+              onTap: () {
+                Navigator.pop(context);
+                // Navigate to profile screen if you have one
+              },
+            ),
+            ListTile(
+              leading: const Icon(Icons.business),
+              title: const Text('Company'),
+              subtitle: Text(currentUser!.companyName.isNotEmpty 
+                  ? currentUser!.companyName 
+                  : 'No company'),
+              onTap: () {
+                Navigator.pop(context);
+              },
+            ),
+            ListTile(
+              leading: const Icon(Icons.location_on),
+              title: const Text('Address'),
+              subtitle: Text(currentUser!.address.isNotEmpty 
+                  ? currentUser!.address 
+                  : 'No address'),
+              onTap: () {
+                Navigator.pop(context);
               },
             ),
-          ),
+            const Divider(),
+          ],
           ListTile(
             leading: const Icon(Icons.home),
             title: const Text('Home'),
@@ .. @@
           ListTile(
             leading: const Icon(Icons.logout),
             title: const Text('Logout'),
-            onTap: () {
-              Navigator.of(context).pushAndRemoveUntil(
-                MaterialPageRoute(builder: (context) => const LoginScreen()),
-                (route) => false,
-              );
-            },
+            onTap: _logout,
           ),
         ],
       ),