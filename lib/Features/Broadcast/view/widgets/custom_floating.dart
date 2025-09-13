import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
 import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';

class FloatingControl extends StatefulWidget {
  get position => null;

  @override
  _FloatingControlState createState() => _FloatingControlState();
}

class _FloatingControlState extends State<FloatingControl> {
  Offset position = Offset(20, 100);
  final double ballSize = 70.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      builder: (context, state) {
        if (!state.isPlaying || state.currentBroadcast == null) return SizedBox.shrink();
        
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanStart: (_) => setState(() => _isDragging = true),
            onPanUpdate: (details) {
              setState(() {
                position = Offset(
                  (position.dx + details.delta.dx).clamp(0.0, MediaQuery.of(context).size.width - ballSize),
                  (position.dy + details.delta.dy).clamp(0.0, MediaQuery.of(context).size.height - ballSize - 100),
                );
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
                position = _snapToEdge(position, context);
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isDragging ? Colors.blue[700] : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  if (state.isPlaying) {
                    context.read<BroadcastCubit>().pause();
                  } else {
                    context.read<BroadcastCubit>().play(state.currentBroadcast!);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _snapToEdge(Offset offset, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double newX = offset.dx;
    double newY = offset.dy;

    if (newX < screenWidth / 2) {
      newX = 20;
    } else {
      newX = screenWidth - ballSize - 20;
    }
    newY = max(100, min(newY, screenHeight - ballSize - 120));

    return Offset(newX, newY);
  }
}