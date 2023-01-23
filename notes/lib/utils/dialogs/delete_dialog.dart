import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_dialog,
    optionBuilder: () => {
      context.loc.cancel: false,
      context.loc.delete: true,
    },
  ).then((value) => value ?? false);
}
