import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/model/broadcast_model.dart';

class BroadcastState {
  final List<Broadcast> broadcasts;
  final Broadcast? currentBroadcast;
  final bool isPlaying;
  final bool isLoading; // إضافة حقل isLoading
  final ProcessingState processingState;
  final Duration position;
  final Duration? duration;
  final String? error;

  BroadcastState({
    required this.broadcasts,
    this.currentBroadcast,
    this.isPlaying = false,
    this.isLoading = false, // قيمة افتراضية
    this.processingState = ProcessingState.idle,
    this.position = Duration.zero,
    this.duration,
    this.error,
  });

  factory BroadcastState.initial() => BroadcastState(
    broadcasts: [
      Broadcast(
        id: '1',
        title: 'Tarateel',
        streamUrl: 'https://qurango.net/radio/tarateel',
        // imageUrl: 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=نغم+FM',
      ),
      Broadcast(
        id: '2',
        title: 'skynewsarabia',
        streamUrl: 'https://radio.skynewsarabia.com/stream/radio/skynewsarabia',
        // imageUrl: 'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=مصر+9090',
      ),
      Broadcast(
        id: '3',
        title: ' ONsport FM',
        streamUrl: 'https://streema.com/radios/play/ONsport_FM',
        // imageUrl: 'https://streema.com/radios/play/ONsport_FM',
      ),
      Broadcast(
        id: '4',
        title: ' Holy Quran Radio',
        streamUrl: 'https://streema.com/radios/Holy_Quran_Radio',
        // imageUrl: 'https://streema.com/radios/Holy_Quran_Radio',
      ),
      Broadcast(
        id: '5',
        title: 'Quran FM Telawa  ',
        streamUrl: 'https://streema.com/radios/Quran_FM_Telawa',
        // imageUrl: 'https://streema.com/radios/Quran_FM_Telawa',
      ),
      Broadcast(
        id: '6',
        title: 'zeno    ',
        streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
        // imageUrl:
        //     'https://via.placeholder.com/150/BB8FCE/FFFFFF?text=مصر+الجديد',
      ),
    ],
  );

  BroadcastState copyWith({
    List<Broadcast>? broadcasts,
    Broadcast? currentBroadcast,
    bool? isPlaying,
    bool? isLoading, // إضافة isLoading إلى copyWith
    ProcessingState? processingState,
    Duration? position,
    Duration? duration,
    String? error,
  }) {
    return BroadcastState(
      broadcasts: broadcasts ?? this.broadcasts,
      currentBroadcast: currentBroadcast ?? this.currentBroadcast,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading, // إضافة isLoading
      processingState: processingState ?? this.processingState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error ?? this.error,
    );
  }
}