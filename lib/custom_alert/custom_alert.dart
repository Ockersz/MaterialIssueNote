import 'package:flutter/material.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final Color? backgroundColor;

  const CustomAlert({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
    this.titleColor,
    this.messageColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: iconColor ?? Colors.red,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: messageColor ?? Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Usage Example
// showDialog(
//   context: context,
//   builder: (context) {
//     return CustomAlert(
//       title: 'Warning !',
//       message: 'Farmer not found.',
//       icon: Icons.warning,
//       iconColor: Colors.red,
//       titleColor: Colors.black,
//       messageColor: Colors.black54,
//       backgroundColor: Colors.white,
//     );
//   },
// );