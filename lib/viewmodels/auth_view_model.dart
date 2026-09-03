import 'package:flutter/foundation.dart';
import 'package:rawang_melodies/data/local/database_helper.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final DatabaseHelper db = DatabaseHelper.instance;

  UserEntity? currentUser;
  bool isLoading = false;
  bool isInitialized = false;
  String? error;

  AuthViewModel() {
    _init();
  }

  Future<void> _init() async {
    final cached = await AuthService.getCachedUser();
    if (cached != null) {
      currentUser = cached;
      await db.upsertUser(cached);
    } else {
      currentUser = await db.getCurrentUser();
    }
    // try refresh profile in background
    final token = await AuthService.getToken();
    if (token != null) {
      try {
        final fresh = await AuthService.fetchMe();
        currentUser = fresh;
        await db.upsertUser(fresh);
      } catch (_) {
        // try refresh token once
        try {
          await AuthService.refresh();
          final fresh2 = await AuthService.fetchMe();
          currentUser = fresh2;
          await db.upsertUser(fresh2);
        } catch (_) {
          // keep cached, will prompt login when 401 on actions
        }
      }
    }
    isInitialized = true;
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;
  bool get isSubscriptionActive => currentUser?.isSubscriptionActive ?? false;

  Future<void> login(String phone, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      final res = await AuthService.login(phone: phone, password: password);
      currentUser = UserEntity.fromMap(res['user']);
      await db.upsertUser(currentUser!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> register({required String phone, required String password, required String name, String? email}) async {
    isLoading = true; error = null; notifyListeners();
    try {
      final res = await AuthService.register(phone: phone, password: password, name: name, email: email);
      currentUser = UserEntity.fromMap(res['user']);
      await db.upsertUser(currentUser!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<String> forgot(String phone) async {
    isLoading = true; notifyListeners();
    try {
      final msg = await AuthService.forgotRequest(phone);
      return msg;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.clearSession();
    await db.clearUsers();
    currentUser = null;
    notifyListeners();
  }

  Future<void> changePassword(String oldPw, String newPw) async {
    isLoading = true; notifyListeners();
    try {
      await AuthService.changePassword(oldPassword: oldPw, newPassword: newPw);
    } finally {
      isLoading = false; notifyListeners();
    }
  }
}
