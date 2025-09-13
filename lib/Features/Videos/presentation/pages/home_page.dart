 import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Core/api/api_services.dart';
import 'package:qemam_task/Features/Broadcast/presentation/pages/broadcast_page.dart';
import 'package:qemam_task/Features/Broadcast/presentation/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Videos/domain/video_repo_impl.dart';
import 'package:qemam_task/Features/Videos/presentation/pages/videos_page.dart';
import 'package:qemam_task/Features/Videos/presentation/videos_cubit/videos_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          BlocProvider(
            create: (_) =>
                VideosCubit(VideoRepoImpl(ApiService(Dio())))..loadVideos(),
            child: VideosPage(),
          ),
          BlocProvider(
            create: (context) => BroadcastCubit(),
            child: BroadcastPage(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: "Reels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts),
            label: "Broadcasts",
          ),
        ],
      ),
    );
  }
}
