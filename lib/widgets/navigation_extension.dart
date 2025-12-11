import 'package:flutter/material.dart';

extension NavExtensions on BuildContext {
  Future<T?> pushTo<T>(Widget page) {
    return Navigator.push(this, _customPageRoute(page) as Route<T>);
  }

  Future<T?> replaceWith<T>(Widget page) {
    return Navigator.pushReplacement(this, _customPageRoute(page) as Route<T>);
  }

  Future<T?> replaceAllWith<T>(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      _customPageRoute(page) as Route<T>,
      (route) => false, // remove everything
    );
  }
}

PageRouteBuilder _customPageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation);

      final fade = Tween(begin: 0.0, end: 1.0).animate(animation);

      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
