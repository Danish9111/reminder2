import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/models/user_model.dart';
import 'package:reminder_app/services/user_service.dart';
import 'package:reminder_app/utils/auth_utils.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  final userService = UserService();
  String? error;

  Future<void> loadUser() async {
    final uid = currentUid;
    // if (user != null) return;
    if (uid == null) {
      error = "User not found";
      notifyListeners();
      return;
    }
    try {
      final user = await userService.getUser(uid);
      _user = user;
    } catch (e) {
      error = e.toString();
    }

    notifyListeners();
  }
}
