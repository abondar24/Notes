import 'package:flutter/material.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<void> showPasswordResetDialog(
  BuildContext context,
) {
  return showGenericDialog(
      context: context,
      title: 'Password reset',
      content: 'Password reset email is sent',
      optionBuilder: () => {
            'OK': null,
          });
}
