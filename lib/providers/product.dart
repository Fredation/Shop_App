import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String? id;
  final String description;
  final String title;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product(
      {required this.id,
      required this.description,
      required this.title,
      required this.imageUrl,
      required this.price,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://shopapp-1d81a-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      print(error);
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
