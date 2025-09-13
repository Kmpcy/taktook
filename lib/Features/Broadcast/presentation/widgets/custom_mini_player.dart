import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_state.dart';


class MiniPlayerIndicator extends StatelessWidget {
  const MiniPlayerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      builder: (context, state) {
        if (state.currentBroadcast == null) return const SizedBox.shrink();

        return Container(
          height: 60,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.radio, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.currentBroadcast!.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (state.isPlaying)
                      const Text(
                        'Playing...',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      )
                    else if (state.processingState == ProcessingState.loading)
                      const Text(
                        'Loading...',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      )
                    else
                      const Text(
                        'Paused',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                  ],
                ),
              ),
              state.processingState == ProcessingState.loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () {
                        if (state.isPlaying) {
                          context.read<BroadcastCubit>().pause();
                        } else if (state.currentBroadcast != null) {
                          context.read<BroadcastCubit>().play(
                            state.currentBroadcast!,
                          );
                        }
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}


