import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../domain/entities/broadcast.dart';
import 'broadcast_state.dart';

class BroadcastCubit extends Cubit<BroadcastState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Broadcast? currentBroadcast;
  StreamSubscription? playerStateSubscription;

  BroadcastCubit() : super(BroadcastState.initial()) {
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    playerStateSubscription =
        audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        stop();
      }
      emit(
        state.copyWith(
          isPlaying: playerState.playing,
          processingState: playerState.processingState,
        ),
      );
    });
  }

  // ===== PLAY =====
  Future<void> play(Broadcast broadcast) async {
    unawaited(_playInternal(broadcast));
  }

  Future<void> _playInternal(Broadcast broadcast) async {
    try {
      if (currentBroadcast?.id == broadcast.id && state.isPlaying) {
        await pause();
        return;
      }

      await audioPlayer.stop();
      currentBroadcast = broadcast;

      emit(state.copyWith(
        error: null,
        processingState: ProcessingState.loading,
      ));

      // ⏳ Timeout on setAudioSource
      await audioPlayer
          .setAudioSource(
            AudioSource.uri(
              Uri.parse(broadcast.streamUrl),
              tag: MediaItem(id: broadcast.id, title: broadcast.title),
            ),
          )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception("Timeout: فشل الاتصال بالمصدر بعد 5 ثواني");
      });

      // ⏳ Timeout on play
      await audioPlayer.play().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception("Timeout: لم يبدأ البث");
        },
      );

      emit(
        state.copyWith(
          currentBroadcast: broadcast,
          isPlaying: true,
          error: null,
          processingState: ProcessingState.ready,
        ),
      );
    } catch (e) {
      String errorMsg = 'فشل في تشغيل البث: ';
      if (e is PlayerException) {
        errorMsg += 'خطأ في مصدر الصوت - تحقق من الرابط أو الاتصال بالإنترنت.';
      } else if (e is SocketException) {
        errorMsg += 'فشل في الاتصال بالخادم.';
      } else {
        errorMsg += e.toString();
      }
      emit(state.copyWith(error: errorMsg, isPlaying: false));
    }
  }

  // ===== PAUSE =====
  Future<void> pause() async {
    unawaited(_pauseInternal());
  }

  Future<void> _pauseInternal() async {
    try {
      await audioPlayer.pause();
      emit(state.copyWith(isPlaying: false));
    } catch (e) {
      emit(state.copyWith(error: 'فشل في إيقاف البث مؤقتاً: ${e.toString()}'));
    }
  }

  // ===== STOP =====
  Future<void> stop() async {
    unawaited(_stopInternal());
  }

  Future<void> _stopInternal() async {
    try {
      await audioPlayer.stop();
      currentBroadcast = null;
      emit(
        state.copyWith(isPlaying: false, currentBroadcast: null, error: null),
      );
    } catch (e) {
      emit(state.copyWith(error: 'فشل في إيقاف البث: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    playerStateSubscription?.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
