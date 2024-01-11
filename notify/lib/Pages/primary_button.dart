import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required VoidCallback onTap,
    required String buttonText,
  }) : _buttonText = buttonText,
        _onTap = onTap;

  final String _buttonText;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap, // Corrected this line
      child: Container(
        width: 370,
        height: 50,
        decoration: ShapeDecoration(
          color: Color(0xFF98C28C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Center(
          child: Text(
            _buttonText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
