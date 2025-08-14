import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/order.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, or your actual server IP for physical devices
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageBaseUrl = 'http://10.0.2.2:8000/storage';
  
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Store token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // Remove token
  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Construct full image URL
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    return '$storageBaseUrl/$imagePath';
  }
  
  // User Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        await storeToken(data['access_token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // User Registration
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String address,
    required String companyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'address': address,
          'company_name': companyName,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        await storeToken(data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get current user
  static Future<User> getCurrentUser() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await removeToken();
    }
  }
  
  // Get products with optional limit and pagination
  static Future<List<Product>> getProducts({int? limit, int? page}) async {
    try {
      String url = '$baseUrl/products';
      List<String> queryParams = [];
      
      if (limit != null) {
        queryParams.add('limit=$limit');
      }
      if (page != null) {
        queryParams.add('page=$page');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        List<Product> products = [];
        for (var productJson in data['products']) {
          products.add(Product.fromJson(productJson));
        }
        return products;
      } else {
        throw Exception(data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get single product
  static Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return Product.fromJson(data['product']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Place order
  static Future<Order> placeOrder(List<Map<String, dynamic>> products) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'products': products,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        return Order.fromJson(data['order']);
      } else {
        throw Exception(data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get user orders
  static Future<List<Order>> getUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        List<Order> orders = [];
        for (var orderJson in data['orders']) {
          orders.add(Order.fromJson(orderJson));
        }
        return orders;
      } else {
        throw Exception(data['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get single order
  static Future<Order> getOrder(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return Order.fromJson(data['order']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}