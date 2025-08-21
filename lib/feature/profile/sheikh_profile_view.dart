import 'package:flutter/material.dart';
import 'package:shamunity/feature/profile/widget/sheikh_profile_widget.dart';

class SheikhProfileScreen extends StatefulWidget {
  final int userId;

  const SheikhProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SheikhProfileScreen> createState() => _SheikhProfileScreenState();
}

class _SheikhProfileScreenState extends State<SheikhProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SheikhProfileWidget(userId: widget.userId),
    );
  }
}
