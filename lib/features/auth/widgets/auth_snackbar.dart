import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';

class AuthSnackbar {
  static void showSuccess(BuildContext context, String message) =>
      TopChip.showSuccess(context, message);

  static void showError(BuildContext context, String message) =>
      TopChip.showError(context, message);

  static void showWarning(BuildContext context, String message) =>
      TopChip.showWarning(context, message);
}
