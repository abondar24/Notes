import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<void> showCannotShareEmptyDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.empty_note_dialog,
    optionBuilder: () => {
      context.loc.ok: null,
    },
  );
}
