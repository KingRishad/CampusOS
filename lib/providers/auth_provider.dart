import 'package:flutter/material.dart';

enum UserRole { student, admin, guest }

class UserModel {
  final String name;
  final String email;
  final UserRole role;
  final String avatarUrl;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl = '',
  });

  String get roleString {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.student:
        return 'Undergraduate Student';
      case UserRole.guest:
        return 'Guest User';
    }
  }
}

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // Default guest login or Shahzaib Ahmad as per screenshot
    loginAsStudent('Shahzaib Ahmad', 'shahzaib@campus.edu');
  }

  void loginAsStudent(String name, String email) {
    _currentUser = UserModel(
      name: name.isNotEmpty ? name : 'Shahzaib Ahmad',
      email: email.isNotEmpty ? email : 'shahzaib@campus.edu',
      role: UserRole.student,
    );
    notifyListeners();
  }

  void loginAsAdmin() {
    _currentUser = UserModel(
      name: 'Dr. Alan Turing',
      email: 'admin@campus.edu',
      role: UserRole.admin,
    );
    notifyListeners();
  }

  void loginAsGuest() {
    _currentUser = UserModel(
      name: 'Guest User',
      email: 'guest@campus.edu',
      role: UserRole.guest,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
