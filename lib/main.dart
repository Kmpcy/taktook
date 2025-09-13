import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:qemam_task/Features/Videos/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.radio.channel',
    androidNotificationChannelName: ' Playing Radio....',
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
    
    );
  }
}
