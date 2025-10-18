import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final Color textColor;
  final VoidCallback onSettingPressed;

  const UserHeader({
    super.key,
    required this.textColor,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/avatar.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello!", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Text(
              "J97 ✏️",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.settings_outlined, size: 28, color: textColor),
          onPressed: onSettingPressed,
        ),
      ],
    );
  }
}
