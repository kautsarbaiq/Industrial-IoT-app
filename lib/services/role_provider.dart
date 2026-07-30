import 'package:flutter/material.dart';

enum AppRole { operator, manager }

/// Tracks the active role. Operators see shop-floor screens; managers see the
/// plant-wide dashboards, analytics and reports.
class RoleProvider extends ChangeNotifier {
  AppRole _role = AppRole.manager;

  AppRole get role => _role;
  bool get isManager => _role == AppRole.manager;
  bool get isOperator => _role == AppRole.operator;

  String get roleLabel => _role == AppRole.manager ? 'Plant Manager' : 'Operator';

  void setRole(AppRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }

  void toggle() {
    _role = _role == AppRole.manager ? AppRole.operator : AppRole.manager;
    notifyListeners();
  }
}
