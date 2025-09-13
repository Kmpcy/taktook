import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_state.dart';

class CustomBroadcastList extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const CustomBroadcastList({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BroadcastCubit, BroadcastState>(
      listener: (context, state) {
        if (state.error != null) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.error!, textAlign: TextAlign.center),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: ' Try Again',
                textColor: Colors.white,
                onPressed: () {
                  if (state.currentBroadcast != null) {
                    context.read<BroadcastCubit>().play(
                      state.currentBroadcast!,
                    );
                  }
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.broadcasts.length,
          itemBuilder: (context, index) {
            final broadcast = state.broadcasts[index];
            final isCurrent = state.currentBroadcast?.id == broadcast.id;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.radio, color: Colors.brown),
                title: Text(
                  broadcast.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ' Click to ${isCurrent && state.isPlaying ? 'Pause' : 'Play'}',
                ),
                trailing:
                    state.processingState == ProcessingState.loading &&
                        isCurrent
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(
                          isCurrent && state.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: isCurrent && state.isPlaying
                              ? Colors.green
                              : Colors.blue,
                          size: 30,
                        ),
                        onPressed: () {
                          if (isCurrent && state.isPlaying) {
                            context.read<BroadcastCubit>().pause();
                          } else {
                            context.read<BroadcastCubit>().play(broadcast);
                          }
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}



























