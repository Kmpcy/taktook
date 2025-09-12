
import 'package:flutter/material.dart';

class BroadcastView extends StatelessWidget {
  const BroadcastView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6, 
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.radio, size: 32),
          title: Text("Broadcast ${index + 1}"),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {},
          ),
        );
      },
    );
  }
}
