import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';

class BroadcastList extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const BroadcastList({Key? key, required this.scaffoldMessengerKey})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<BroadcastCubit, BroadcastState>(
      listener: (context, state) {
        if (state.error != null) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.error!, textAlign: TextAlign.center),
              backgroundColor: Colors.red[700],
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'إعادة المحاولة',
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
      child: BlocBuilder<BroadcastCubit, BroadcastState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.broadcasts.length,
            itemBuilder: (context, index) {
              final broadcast = state.broadcasts[index];
              final isCurrent = state.currentBroadcast?.id == broadcast.id;
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(Icons.radio, size: 40, color: Colors.blue),
                  title: Text(
                    broadcast.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Click to play'),
                  trailing: isCurrent
                      ? Icon(
                          state.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: state.isPlaying ? Colors.green : Colors.blue,
                          size: 30,
                        )
                      : Icon(
                          Icons.play_circle_filled,
                          color: Colors.blue,
                          size: 30,
                        ),
                  onTap: () => context.read<BroadcastCubit>().play(broadcast),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
