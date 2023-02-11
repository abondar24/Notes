import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<void> showSyncDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sync_dialog,
    content: text,
    optionBuilder: () => {
      context.loc.ok: null,
    },
  );
}
