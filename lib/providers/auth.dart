import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    if (_userId != null) {
      return _userId;
    }
    return null;
  }

  Future _authenticate(
      String? email, String? password, String? authenticateMethod) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$authenticateMethod?key=AIzaSyBWo6dVN7s0ZqqW_eblrTC6NW3Ey2yXUcU');
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': 'aslam@gmail.com',
          'password': '123456',
          'returnSecureToken': true,
        },
      ),
    );

    _token = json.decode(response.body)['idToken'];
    _userId = json.decode(response.body)['localId'];
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(json.decode(response.body)['expiresIn']),
      ),
    );

    // print(_token);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate?.toIso8601String()
    });
    prefs.setString('user', userData);
    autoLogOut();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user')) {
      return false;
    }

    final extractedData =
        json.decode(prefs.getString('user')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    // print(_token);
    // print(_userId);
    // print(_expiryDate);
    autoLogOut();

    notifyListeners();
    return true;
  }

  Future<void> signUp(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void autoLogOut() async {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final time = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer.periodic(Duration(seconds: time!), (timer) {
      logOut();
    });
  }

  void logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (_authTimer != null) {
      _authTimer?.cancel();
    }

    notifyListeners();
  }
}
