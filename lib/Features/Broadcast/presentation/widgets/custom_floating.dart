import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_state.dart';

class FloatingControl extends StatefulWidget {
  const FloatingControl({super.key});

  @override
  FloatingControlState createState() => FloatingControlState();
}

class FloatingControlState extends State<FloatingControl> {
  Offset position = const Offset(20, 100);
  final double ballSize = 70.0;
  bool isDragging = false;

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
    newY = newY.clamp(100, screenHeight - ballSize - 120);

    return Offset(newX, newY);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              (position.dx + details.delta.dx).clamp(
                0.0,
                MediaQuery.of(context).size.width - ballSize,
              ),
              (position.dy + details.delta.dy).clamp(
                0.0,
                MediaQuery.of(context).size.height - ballSize - 100,
              ),
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            isDragging = false;
            position = _snapToEdge(position, context);
          });
        },
        child: BlocBuilder<BroadcastCubit, BroadcastState>(
          builder: (context, state) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDragging ? Colors.blue[700] : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: state.processingState == ProcessingState.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        final cubit = context.read<BroadcastCubit>();
                        if (state.isPlaying) {
                          cubit.pause();
                        } else if (state.currentBroadcast != null) {
                          cubit.play(state.currentBroadcast!);
                        }
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

