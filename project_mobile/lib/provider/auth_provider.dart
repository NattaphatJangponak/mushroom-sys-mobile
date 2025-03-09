// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// class AuthProvider extends ChangeNotifier {
//   final Dio _dio = Dio();
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   Map<String, dynamic>? _user;

//   Map<String, dynamic>? get user => _user;

//   Future<void> loadUser() async {
//     String? token = await _storage.read(key: "token");

//     if (token != null) {
//       bool isExpired = JwtDecoder.isExpired(token);
//       if (isExpired) {
//         logout();
//       } else {
//         Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//         _user = {
//           "id": decodedToken["id"],
//           "username": decodedToken["username"]
//         };
//         _dio.options.headers["Authorization"] = "Bearer $token";
//         notifyListeners();
//       }
//     }
//   }

//   Future<bool> login(String username, String password) async {
//     try {
//       Response response = await _dio.post(
//         "http://localhost:5000/api/auth/login",
//         data: {"username": username, "password": password},
//       );
//       String token = response.data["token"];
//       await _storage.write(key: "token", value: token);
//       await loadUser();
//       return true;
//     } catch (error) {
//       print("❌ Login failed: $error");
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     await _storage.delete(key: "token");
//     _user = null;
//     _dio.options.headers.remove("Authorization");
//     notifyListeners();
//   }
// }
