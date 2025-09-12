import 'package:flutter/material.dart';
import 'package:qemam_task/Features/home.dart';

void main() {
  runApp(const TakTok());
}

class TakTok extends StatelessWidget {
  const TakTok({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeView(),
    );
  }
}
