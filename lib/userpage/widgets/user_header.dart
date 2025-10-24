import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String username;
  final String email;
  final Color textColor;
  final VoidCallback onSettingPressed;

  const UserHeader({
    Key? key,
    required this.username,
    required this.email,
    required this.textColor,
    required this.onSettingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔹 Avatar dùng ảnh từ assets thay vì ô tròn
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/user.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 16),

        //Tên & email người dùng
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        //Nút cài đặt
        IconButton(
          onPressed: onSettingPressed,
          icon: Icon(Icons.settings, color: textColor, size: 28),
          tooltip: 'Cài đặt tài khoản',
        ),
      ],
    );
  }
}
