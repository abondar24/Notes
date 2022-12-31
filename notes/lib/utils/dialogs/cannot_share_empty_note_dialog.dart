import 'package:flutter/material.dart';
import 'package:notes/utils/generics/generic_dialog.dart';

Future<void> showCannotShareEmptyDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Sharing',
    content: 'Your note is empty',
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
