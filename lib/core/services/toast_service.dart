import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  static void show({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    ToastLength length = ToastLength.LONG,
    Color backgroundColor = Colors.green,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
    );
  }

  static void showSuccess(String message) {
    show(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showError(String message) {
    show(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void showWarning(String message) {
    show(
      message: message,
      backgroundColor: Colors.orange,
    );
  }

  static void showInfo(String message) {
    show(
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  static void showCustom({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
  }) {
    show(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}
