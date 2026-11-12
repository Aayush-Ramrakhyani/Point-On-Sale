import 'package:flutter/material.dart';

Widget textField(
    TextEditingController controller, String? hintText, String? labelText) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black)),
    ),
  );
}

Widget textFieldWithIcon(
    TextEditingController controller,
    String? hintText,
    String? labelText,
    bool showpassword,
    Icon icon,
    VoidCallback onPressed) {
  return TextField(
    obscureText: showpassword,
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixIcon: IconButton(icon: icon, onPressed: onPressed),
      labelStyle:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black)),
    ),
  );
}
