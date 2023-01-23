import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.logout,
    content: context.loc.logout_dialog,
    optionBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout: true,
    },
  ).then((value) => value ?? false);
}
