import 'package:flutter/material.dart';

void showAlertDialog(
  BuildContext context, {
  required String title,
  required String description,
  void Function()? onConfirm,
  String confirmText = "Continue",
  void Function()? onDecline,
  String declineText = "Cancel",
}) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(declineText),
    onPressed: () {
      if (onDecline != null) onDecline();
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text(confirmText),
    onPressed: () {
      if (onConfirm != null) onConfirm();
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(description),
    actions: [
      cancelButton,
      continueButton,
    ],
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
