import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../providers/cart.dart';
//import '../providers/products_providers.dart';

class OrderItem {
  final String id;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.price,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(
    this._orders,
    this.authToken,
    this.userId,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final url = Uri.parse(
          'https://shopapp-1d81a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
      final response = await http.get(url);
      final List<OrderItem> _loadedOrders = [];
      final _extractedData =
          json.decode(response.body.toString()) as Map<String, dynamic>;
      if (_extractedData == null) {
        return;
      }

      _extractedData.forEach((orderId, orderData) {
        _loadedOrders.add(OrderItem(
          id: orderId,
          price: orderData['price'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ));
      });
      _orders = _loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final dateStamp = DateTime.now();
    final url = Uri.parse(
        'https://shopapp-1d81a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.post(
      url,
      body: json.encode({
        'price': total,
        'dateTime': dateStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body.toString())['name'],
        price: total,
        products: cartProducts,
        dateTime: dateStamp,
      ),
    );
    notifyListeners();
  }
}
