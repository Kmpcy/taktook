
import 'package:flutter/material.dart';

class CustomFlowButtons extends StatelessWidget {
  const CustomFlowButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        children: const [
          Icon(Icons.play_arrow, size: 36, color: Colors.white),
          SizedBox(height: 16),
          Icon(Icons.volume_up, size: 36, color: Colors.white),
        ],
      ),
    );
  }
}
