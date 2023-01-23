import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<void> showPasswordResetDialog(
  BuildContext context,
) {
  return showGenericDialog(
      context: context,
      title: context.loc.password_reset_dialog_title,
      content: context.loc.password_reset_dialog,
      optionBuilder: () => {
            context.loc.ok: null,
          });
}
