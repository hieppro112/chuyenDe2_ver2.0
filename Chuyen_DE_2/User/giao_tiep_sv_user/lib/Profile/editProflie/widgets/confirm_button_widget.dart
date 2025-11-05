import 'package:flutter/material.dart';

class ConfirmButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isActive;

  const ConfirmButtonWidget({
    super.key,
    required this.onPressed,
    this.buttonText = "Xác nhận",
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? const Color.fromARGB(255, 0, 85, 150)
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: isActive ? 5 : 0,
        ),
        onPressed: isActive ? onPressed : null,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
