import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/domain/entities/broadcast.dart';

class BroadcastState {
  final List<Broadcast> broadcasts;
  final Broadcast? currentBroadcast;
  final bool isPlaying;
  final ProcessingState processingState;
  final Duration position;
  final Duration? duration;
  final String? error;

  BroadcastState({
    required this.broadcasts,
    this.currentBroadcast,
    this.isPlaying = false,
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
      ),
      Broadcast(
        id: '2',
        title: 'Radio',
        streamUrl: 'https://qurango.net/radio/tarateel',
      ),
      Broadcast(
        id: '3',
        title: ' Quran',
        streamUrl: 'https://qurango.net/radio/tarateel',
      ),
      Broadcast(
        id: '4',
        title: 'HolyQuran Radio',
        streamUrl: 'https://qurango.net/radio/tarateel',
      ),
      Broadcast(
        id: '5',
        title: 'Sky Arabia',
        streamUrl: 'https://radio.skynewsarabia.com/stream/radio/skynewsarabia',
      ),
      Broadcast(
        id: '6',
        title: 'News Arabia',
        streamUrl: 'https://radio.skynewsarabia.com/stream/radio/skynewsarabia',
      ),
    ],
  );

  BroadcastState copyWith({
    List<Broadcast>? broadcasts,
    Broadcast? currentBroadcast,
    bool? isPlaying,
    ProcessingState? processingState,
    Duration? position,
    Duration? duration,
    String? error,
  }) {
    return BroadcastState(
      broadcasts: broadcasts ?? this.broadcasts,
      currentBroadcast: currentBroadcast ?? this.currentBroadcast,
      isPlaying: isPlaying ?? this.isPlaying,
      processingState: processingState ?? this.processingState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error ?? this.error,
    );
  }
}
