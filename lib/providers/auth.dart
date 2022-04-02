import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shop_app/screens/auth_screen.dart';

import '../models/http_exceptions.dart';

class Auth with ChangeNotifier {
  String? token;
  DateTime? expiryDate;
  String? userId;
  Timer? authTimer;

  Auth({this.token, this.expiryDate, this.userId});

  String? get userIds {
    return userId;
  }

  bool get isAuth {
    return token != null && token != '' && userId != null && userId != '';
  }

  String? get tokens {
    if (expiryDate!.isAfter(DateTime.now()) &&
        token != null &&
        expiryDate != null) {
      return token;
    } else {
      return null;
    }
  }

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBoJjRAfDWgQtPOvrgc5c0_2uahQKKjKqQ');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      print(response.body);
      final responseData = json.decode(response.body.toString());
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      token = responseData['idToken'];
      userId = responseData['localId'];
      expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'userId': userId,
        'expiryDate': expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logIn(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBoJjRAfDWgQtPOvrgc5c0_2uahQKKjKqQ');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      print(response.body);
      final responseData = json.decode(response.body.toString());
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      userId = responseData['localId'];
      expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': token,
        'userId': userId,
        'expiryDate': expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, dynamic>;
    final _expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (_expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    token = extractedUserData['token'];
    userId = extractedUserData['userId'];
    expiryDate = _expiryDate;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    token = null;
    userId = null;
    expiryDate = null;
    if (authTimer != null) {
      authTimer!.cancel();
      authTimer = null;
    }

    final pref = await SharedPreferences.getInstance();
    pref.clear();

    notifyListeners();
    //return token = null;
  }

  Future<void> autoLogOut() async {
    if (authTimer != null) {
      authTimer!.cancel();
    }

    final timeToExpiry = expiryDate!.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: 10), logOut);
    //token = null;
    //print(token);
    notifyListeners();
  }
}


// class AutoLogin<T extends Auth> extends StatelessWidget {
//   const AutoLogin({ Key? key }) : super(key: key);


//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//     );
//   }
// }
