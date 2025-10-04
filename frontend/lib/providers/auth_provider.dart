import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await StorageService().getToken();
    final user = await StorageService().getUser();
    
    if (token != null && user != null) {
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success']) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await StorageService().saveToken(token);
        _user = UserModel.fromJson(userData);
        await StorageService().saveUser(_user!);
        
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Network error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    List<String>? skills,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'skills': skills ?? [],
          'bio': bio ?? '',
        },
      );

      if (response.data['success']) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await StorageService().saveToken(token);
        _user = UserModel.fromJson(userData);
        await StorageService().saveUser(_user!);
        
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Network error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService().clearAll();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    List<String>? skills,
    String? bio,
    String? resumeLink,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().put(
        ApiConstants.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (skills != null) 'skills': skills,
          if (bio != null) 'bio': bio,
          if (resumeLink != null) 'resumeLink': resumeLink,
        },
      );

      if (response.data['success']) {
        _user = UserModel.fromJson(response.data['user']);
        await StorageService().saveUser(_user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Update failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}