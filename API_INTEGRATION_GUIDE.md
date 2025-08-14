# API_INTEGRATION_GUIDE

## Overview
You are an AI agent that will integrate **two separate projects** with the same API:
1. **React.js Project** → Admin dashboard & login.
2. **Flutter Project** → End-user mobile application.

---

## 1️⃣ React.js Project (Admin)
**Goals:**
- Use `.jsx` files only (no `.tsx`).
- Connect **login page** to API authentication (admin role).
- After login:
  - Integrate all remaining **admin-related API requests** into the dashboard.
  - Modify `Dashboard.jsx` to match API data format.
- UI Changes:
  - Remove **navbar** from dashboard view only (keep it in other site pages).
  - Remove **navbar** from login page too.
  - On dashboard page: place form fields side-by-side (not stacked vertically) while keeping it responsive.
  - Keep consistent spacing, alignment, and typography.

**Tech Notes:**
- Use `axios` or `fetch` for API calls.
- Store tokens securely (`localStorage` or `sessionStorage`).
- Apply loading states & error handling for all API requests.

---

## 2️⃣ Flutter Project (User App)
**Goals:**
- Integrate API endpoints for **user role only** (no admin requests).
- Connect login screen to API authentication.
- After login, replace all placeholder/static data with real API responses.
- UI Improvements:
  - Modern look with better alignment, spacing, and responsive behavior for mobile devices.
  - Smooth navigation between pages after login.

**Tech Notes:**
- Use `dio` or `http` package for API calls.
- Store tokens securely using `flutter_secure_storage` or similar.
- Implement proper loading & error states.

---

## Shared Requirements
- The React dashboard and Flutter app should use the **same API base URL**.
- All API requests should include authentication token in headers after login.
- Ensure consistent design system and user experience across both platforms.
- Replace dummy data with actual API-driven data in both projects.

---

## Deliverables
- Updated React admin dashboard (`.jsx` files only) fully connected to admin API.
- Updated Flutter user app fully connected to user API.
- UI improvements applied to both projects.

# Verde Cem API Integration Guide

## Base URL
```
http://localhost:8000/api
```

## Authentication

### JWT Token Usage
All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer {your_jwt_token}
```

### Token Storage
- Store the token securely (AsyncStorage for React Native, SharedPreferences for Flutter)
- Include token in all authenticated requests
- Handle token expiration (401 responses)

---

## User Authentication Endpoints

### 1. User Registration
**POST** `/auth/signup`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+1234567890",
  "address": "123 Main St, City, Country",
  "company_name": "ABC Company"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "address": "123 Main St, City, Country",
    "company_name": "ABC Company",
    "created_at": "2025-01-01T00:00:00.000000Z"
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

**Error Response (422):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["This email is already registered"],
    "password": ["Password confirmation does not match"]
  }
}
```

### 2. User Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 2592000
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "error": "Email or password is incorrect"
}
```

### 3. Get Current User
**POST** `/auth/me`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "address": "123 Main St, City, Country",
    "company_name": "ABC Company",
    "created_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### 4. Refresh Token
**POST** `/auth/refresh`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 2592000
}
```

### 5. User Logout
**POST** `/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Successfully logged out"
}
```

---

## Admin Authentication Endpoints

### 1. Admin Login
**POST** `/admin/login`

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 2592000
}
```

### 2. Admin Registration (Protected)
**POST** `/admin/signup`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "name": "New Admin",
  "email": "newadmin@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

### 3. Admin Logout
**POST** `/admin/logout`

**Headers:**
```
Authorization: Bearer {admin_token}
```

### 4. Delete Admin (Protected)
**DELETE** `/admin/{id}`

**Headers:**
```
Authorization: Bearer {admin_token}
```

---

## Product Endpoints

### 1. Get All Products (Public)
**GET** `/products`

**Success Response (200):**
```json
{
  "success": true,
  "products": [
    {
      "id": 1,
      "name": "Product Name",
      "price": "100.00",
      "description": "Product description",
      "image": "products/image.jpg",
      "image_url": "http://localhost:8000/storage/products/image.jpg",
      "created_at": "2025-01-01T00:00:00.000000Z",
      "updated_at": "2025-01-01T00:00:00.000000Z"
    }
  ]
}
```

### 2. Get Single Product (Public)
**GET** `/products/{id}`

**Success Response (200):**
```json
{
  "success": true,
  "product": {
    "id": 1,
    "name": "Product Name",
    "price": "100.00",
    "description": "Product description",
    "image": "products/image.jpg",
    "image_url": "http://localhost:8000/storage/products/image.jpg",
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### 3. Create Product (Admin Only)
**POST** `/products`

**Headers:**
```
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
name: Product Name
price: 100.00
description: Product description
image: [file upload]
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Product created successfully",
  "product": {
    "id": 1,
    "name": "Product Name",
    "price": "100.00",
    "description": "Product description",
    "image": "products/image.jpg",
    "image_url": "http://localhost:8000/storage/products/image.jpg",
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### 4. Update Product (Admin Only)
**PUT** `/products/{id}`

**Headers:**
```
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
name: Updated Product Name
price: 150.00
description: Updated description
image: [file upload] (optional)
```

### 5. Delete Product (Admin Only)
**DELETE** `/products/{id}`

**Headers:**
```
Authorization: Bearer {admin_token}
```

---

## Order Endpoints

### 1. Place Order (User Only)
**POST** `/orders`

**Headers:**
```
Authorization: Bearer {user_token}
```

**Request Body:**
```json
{
  "products": [
    {
      "id": 1,
      "quantity": 2
    },
    {
      "id": 3,
      "quantity": 1
    }
  ]
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Order placed successfully",
  "order": {
    "id": 1,
    "user_id": 1,
    "status": "placed",
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z",
    "products": [
      {
        "id": 1,
        "name": "Product Name",
        "price": "100.00",
        "pivot": {
          "quantity": 2,
          "price": "100.00"
        }
      }
    ]
  }
}
```

### 2. Get User Orders (User Only)
**GET** `/orders`

**Headers:**
```
Authorization: Bearer {user_token}
```

**Success Response (200):**
```json
{
  "success": true,
  "orders": [
    {
      "id": 1,
      "user_id": 1,
      "status": "placed",
      "created_at": "2025-01-01T00:00:00.000000Z",
      "updated_at": "2025-01-01T00:00:00.000000Z",
      "products": [
        {
          "id": 1,
          "name": "Product Name",
          "price": "100.00",
          "pivot": {
            "quantity": 2,
            "price": "100.00"
          }
        }
      ]
    }
  ]
}
```

### 3. Get Single Order (User Only)
**GET** `/orders/{id}`

**Headers:**
```
Authorization: Bearer {user_token}
```

### 4. Get All Orders (Admin Only)
**GET** `/orders`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Success Response (200):**
```json
{
  "success": true,
  "orders": [
    {
      "id": 1,
      "user_id": 1,
      "status": "placed",
      "created_at": "2025-01-01T00:00:00.000000Z",
      "updated_at": "2025-01-01T00:00:00.000000Z",
      "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "address": "123 Main St, City, Country",
        "company_name": "ABC Company"
      },
      "products": [
        {
          "id": 1,
          "name": "Product Name",
          "price": "100.00",
          "pivot": {
            "quantity": 2,
            "price": "100.00"
          }
        }
      ]
    }
  ]
}
```

### 5. Update Order Status (Admin Only)
**PATCH** `/orders/{id}/status`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "status": "processing"
}
```

**Valid Status Values:** `placed`, `processing`, `completed`

---

## Notification Endpoints

### 1. Get Active Notifications (Public)
**GET** `/notifications`

**Success Response (200):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Notification Title",
      "body": "Notification body content",
      "is_active": true,
      "created_at": "2025-01-01T00:00:00.000000Z",
      "updated_at": "2025-01-01T00:00:00.000000Z",
      "admin": {
        "id": 1,
        "name": "Admin Name"
      }
    }
  ]
}
```

### 2. Get Single Notification (Public)
**GET** `/notifications/{id}`

### 3. Get All Notifications (Admin Only)
**GET** `/admin/notifications`

**Headers:**
```
Authorization: Bearer {admin_token}
```

### 4. Create Notification (Admin Only)
**POST** `/admin/notifications`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "title": "New Notification",
  "body": "Notification content",
  "is_active": true
}
```

### 5. Update Notification (Admin Only)
**PUT** `/admin/notifications/{id}`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "body": "Updated content",
  "is_active": false
}
```

### 6. Delete Notification (Admin Only)
**DELETE** `/admin/notifications/{id}`

**Headers:**
```
Authorization: Bearer {admin_token}
```

---

## Error Handling

### Common HTTP Status Codes
- **200**: Success
- **201**: Created
- **400**: Bad Request
- **401**: Unauthorized (Invalid/missing token)
- **403**: Forbidden (Insufficient permissions)
- **404**: Not Found
- **422**: Validation Error
- **500**: Server Error

### Error Response Format
```json
{
  "success": false,
  "message": "Error description",
  "error": "Error type",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

---

## React Native Integration Example

```javascript
// API Service
class ApiService {
  constructor() {
    this.baseURL = 'http://localhost:8000/api';
    this.token = null;
  }

  setToken(token) {
    this.token = token;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.token) {
      headers.Authorization = `Bearer ${this.token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Request failed');
      }

      return data;
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }

  // Auth methods
  async login(email, password) {
    const data = await this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    this.setToken(data.access_token);
    return data;
  }

  async signup(userData) {
    const data = await this.request('/auth/signup', {
      method: 'POST',
      body: JSON.stringify(userData),
    });
    this.setToken(data.token);
    return data;
  }

  // Product methods
  async getProducts() {
    return await this.request('/products');
  }

  async getProduct(id) {
    return await this.request(`/products/${id}`);
  }

  // Order methods
  async placeOrder(products) {
    return await this.request('/orders', {
      method: 'POST',
      body: JSON.stringify({ products }),
    });
  }

  async getUserOrders() {
    return await this.request('/orders');
  }
}

export default new ApiService();
```

---

## Flutter Integration Example

```dart
// API Service
class ApiService {
  static const String baseURL = 'http://localhost:8000/api';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseURL$endpoint');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    try {
      final response = await http.request(
        url,
        method: method,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(data['message'] ?? 'Request failed');
      }

      return data;
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Auth methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await request('/auth/login',
        method: 'POST',
        body: {'email': email, 'password': password});
    setToken(data['access_token']);
    return data;
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    final data = await request('/auth/signup',
        method: 'POST', body: userData);
    setToken(data['token']);
    return data;
  }

  // Product methods
  static Future<Map<String, dynamic>> getProducts() async {
    return await request('/products');
  }

  static Future<Map<String, dynamic>> getProduct(int id) async {
    return await request('/products/$id');
  }

  // Order methods
  static Future<Map<String, dynamic>> placeOrder(List<Map<String, dynamic>> products) async {
    return await request('/orders',
        method: 'POST', body: {'products': products});
  }

  static Future<Map<String, dynamic>> getUserOrders() async {
    return await request('/orders');
  }
}
```

---

## Testing the API

### Using Postman/Insomnia
1. Set base URL: `http://localhost:8000/api`
2. For authenticated requests, add header: `Authorization: Bearer {token}`
3. For file uploads, use `multipart/form-data` content type

### Using cURL
```bash
# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Get products
curl -X GET http://localhost:8000/api/products

# Place order (with token)
curl -X POST http://localhost:8000/api/orders \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"products":[{"id":1,"quantity":2}]}'
```

---

## Important Notes

1. **Token Management**: Always store tokens securely and handle token expiration
2. **Error Handling**: Implement proper error handling for network failures and API errors
3. **Loading States**: Show loading indicators during API calls
4. **Offline Support**: Consider implementing offline caching for better UX
5. **Image URLs**: Product images are served from `/storage/` path
6. **Validation**: Always validate user input before sending to API
7. **Rate Limiting**: Be mindful of API rate limits in production

This guide provides all the necessary information for AI agents to integrate with your Verde Cem API for both React Native and Flutter projects.
