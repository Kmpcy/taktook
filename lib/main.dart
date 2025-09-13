import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:qemam_task/Features/Broadcast/view/widgets/custom_mini_player.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';
import 'package:qemam_task/Features/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.radio.channel',
    androidNotificationChannelName: 'تشغيل الراديو',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );
  
  runApp(TakTok());
}
class TakTok extends StatelessWidget {
  const TakTok({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeView(),
      // builder: (context, child) {
      //       return BlocBuilder<BroadcastCubit, BroadcastState>(
      //         builder: (context, state) {
      //           if (state.currentBroadcast != null && state.isPlaying) {
      //             return Column(
      //               children: [
      //                 Expanded(child: child!),
      //                 MiniPlayerIndicator(),
      //               ],
      //             );
      //           }
      //           return child!;
      //         },
      //       );
      //     },
    );
  }
}
