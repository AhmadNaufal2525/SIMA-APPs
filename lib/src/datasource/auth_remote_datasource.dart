import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sima_app/src/presentation/router/routes.dart';
import 'package:sima_app/src/presentation/screen/home/home_screen.dart';
import 'package:sima_app/src/utils/constant.dart';
import 'package:sima_app/src/widgets/toast_widget.dart';

class AuthRemoteDataSource {
  String? token;

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      final uri = Uri.parse('${Constant.baseUrl}${Constant.loginPath}');
      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final Map<String, String> body = {'email': email, 'password': password};

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String token = responseData['token'];
        String username = responseData['user']['username'];
        String userId = responseData['user']['id'];
        String role = responseData['user']['role'];
        
        if (role != 'user') {
          showToast('Unauthorized access', false);
          return;
        }

        showToast('Login successful', true);

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(username: username, userId: userId, token: token),
          ),
        );
        });
      } else if (response.statusCode == 404) {
        showToast('Email not registered', false);
      } else if (response.statusCode == 401) {
        showToast('Wrong password', false);
      } else {
        showToast('Login Failed', false);
      }
    } catch (e) {
      showToast('An error occurred during Login.', false);
    }
  }

  Future<void> signUp(BuildContext context, String email, String password,
      String username) async {
    try {
      final uri = Uri.parse('${Constant.baseUrl}${Constant.registerPath}');
      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final Map<String, String> body = {
        'email': email,
        'password': password,
        'username': username
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        showToast('Registration successful', true);
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(
            context,
            Routes.loginScreen,
          );
        });
      } else if (response.statusCode == 400) {
        showToast('Email already registered', false);
      } else {
        showToast('Registration Failed', false);
      }
    } catch (e) {
      showToast('An error occurred during registration.', false);
    }
  }

  Future<void> signOut(BuildContext context, String token) async {
    try {
      this.token = token;

      final response = await http.post(
        Uri.parse('${Constant.baseUrl}${Constant.logoutPath}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(
            context,
            Routes.initScreen,
          );
        });
        showToast('Logout successful', true);
      } else {
        showToast('Logout failed. Please try again.', false);
      }
    } catch (error) {
      showToast('An error occurred during logout.', false);
    }
  }
}
