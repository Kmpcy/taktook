import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';

class MiniPlayerIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      builder: (context, state) {
        if (state.currentBroadcast == null) {
          return SizedBox.shrink();
        }
        return Container(
          height: 60,
          color: Colors.grey[300],
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.currentBroadcast!.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  if (state.isPlaying) {
                    context.read<BroadcastCubit>().pause();
                  } else if (state.currentBroadcast != null) {
                    context.read<BroadcastCubit>().play(state.currentBroadcast!);
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