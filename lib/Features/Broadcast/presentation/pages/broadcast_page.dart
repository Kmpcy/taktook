import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_state.dart';
import 'package:qemam_task/Features/Broadcast/presentation/widgets/custom_broadcast_list.dart';
import 'package:qemam_task/Features/Broadcast/presentation/widgets/custom_floating.dart';
import 'package:qemam_task/Features/Broadcast/presentation/widgets/custom_mini_player.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({super.key});

  @override
  BroadcastPageState createState() => BroadcastPageState();
}

class BroadcastPageState extends State<BroadcastPage> {
  OverlayEntry? floatingOverlay;
  bool isOverlayInserted = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  BroadcastCubit? cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupFloatingControl();
    });
  }

  void setupFloatingControl() {
    floatingOverlay = OverlayEntry(
      builder: (context) {
        if (cubit == null) return const SizedBox.shrink();

        return BlocProvider.value(
          value: cubit!,
          child: const FloatingControl(),
        );
      },
    );
  }

  void insertOverlay() {
    if (floatingOverlay != null && !isOverlayInserted) {
      Overlay.of(context).insert(floatingOverlay!);
      setState(() => isOverlayInserted = true);
    }
  }

  void removeOverlay() {
    if (isOverlayInserted) {
      floatingOverlay?.remove();
      setState(() => isOverlayInserted = false);
    }
  }

  @override
  void dispose() {
    floatingOverlay?.remove();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, BroadcastState state) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(state.error!, textAlign: TextAlign.center),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Try Again',
          textColor: Colors.white,
          onPressed: () {
            if (state.currentBroadcast != null) {
              context.read<BroadcastCubit>().play(state.currentBroadcast!);
            }
          },
        ),
      ),
    );
    context.read<BroadcastCubit>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: BlocProvider(
        create: (context) {
          cubit = BroadcastCubit();
          return cubit!;
        },
        child: BlocConsumer<BroadcastCubit, BroadcastState>(
          listener: (context, state) {
            if (state.currentBroadcast != null && !isOverlayInserted) {
              insertOverlay();
            } else if (state.currentBroadcast == null && isOverlayInserted) {
              removeOverlay();
            }

            if (state.error != null && state.error!.isNotEmpty) {
              _showErrorSnackBar(context, state);
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Broadcasts',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ),
              body: CustomBroadcastList(scaffoldMessengerKey: scaffoldMessengerKey),
              bottomNavigationBar: const MiniPlayerIndicator(),
            );
          },
        ),
      ),
    );
  }
}
