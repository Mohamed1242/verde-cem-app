import 'product.dart';
import 'user.dart';

class OrderProduct {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final double orderPrice;

  OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.orderPrice,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] ?? {};
    return OrderProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(pivot['quantity'].toString()) ?? 1,
      orderPrice: double.tryParse(pivot['price'].toString()) ?? 0.0,
    );
  }

  double get totalPrice => orderPrice * quantity;
}

class Order {
  final int id;
  final int userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderProduct> products;
  final User? user;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderProduct> orderProducts = [];
    if (json['products'] != null) {
      for (var productJson in json['products']) {
        orderProducts.add(OrderProduct.fromJson(productJson));
      }
    }

    User? orderUser;
    if (json['user'] != null) {
      orderUser = User.fromJson(json['user']);
    }

    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'placed',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      products: orderProducts,
      user: orderUser,
    );
  }

  double get totalAmount {
    return products.fold(0.0, (sum, product) => sum + product.totalPrice);
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'placed':
        return 'Order Placed';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}