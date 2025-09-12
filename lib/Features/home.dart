import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Core/api/api_services.dart';
import 'package:qemam_task/Features/Broadcast/view/broadcast_view.dart';
import 'package:qemam_task/Features/Videos/Repo/video_repo_impl.dart';
import 'package:qemam_task/Features/Videos/view/videos_view.dart';
import 'package:qemam_task/Features/Videos/view_model/videos_cubit/videos_cubit.dart';

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
          const BroadcastView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: "Videos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts),
            label: "Broadcast",
          ),
        ],
      ),
    );
  }
}
