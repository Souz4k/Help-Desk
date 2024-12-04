import "package:flutter/material.dart";

void mostrarSnackBar({
  required BuildContext context,
  required String texto,
  Color? cor, // Parâmetro opcional para cor
}) {
  SnackBar snackBar = SnackBar(
    content: Text(
      texto,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: cor ?? Colors.green, // Cor padrão é verde
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    duration: const Duration(seconds: 4),
    action: SnackBarAction(
      label: "OK",
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
