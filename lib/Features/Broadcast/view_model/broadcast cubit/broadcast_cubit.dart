import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qemam_task/Features/Broadcast/model/broadcast_model.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';

class BroadcastCubit extends Cubit<BroadcastState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isChanging = false;
  Broadcast? _currentBroadcast;
  String? _lastError;

  BroadcastCubit() : super(BroadcastState.initial()) {
    _init();
  }

  void _init() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processing = playerState.processingState;

      if (processing == ProcessingState.completed) {
        stop();
        return;
      }

      emit(state.copyWith(
        isPlaying: isPlaying,
        processingState: processing,
        isLoading: false, // إيقاف التحميل عند وجود حالة جديدة
        error: null, // مسح الأخطاء عند نجاح التشغيل
      ));
      _lastError = null;
    });

    _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration));
    });
  }

  String _formatError(Object e) {
    final s = e.toString();
    if (s.toLowerCase().contains('connection') || s.toLowerCase().contains('abort')) {
      return 'فشل الاتصال بالخادم';
    }
    return 'حدث خطأ أثناء التشغيل';
  }

  Future<void> play(Broadcast broadcast) async {
    if (_isChanging) return;
    _isChanging = true;

    // بدء التحميل - إظهار أيقونة التحميل
    emit(state.copyWith(
      currentBroadcast: broadcast,
      isLoading: true,
      error: null,
    ));
    _currentBroadcast = broadcast;

    try {
      if (_currentBroadcast?.id == broadcast.id) {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
          emit(state.copyWith(isPlaying: false, isLoading: false, error: null));
        } else {
          await _audioPlayer.play();
          emit(state.copyWith(isPlaying: true, isLoading: false, error: null));
        }
        _isChanging = false;
        return;
      }

      try {
        await _audioPlayer.stop();
      } catch (_) {}

      bool loaded = false;
      try {
        await _audioPlayer.setUrl(broadcast.streamUrl);
        loaded = true;
      } catch (e1) {
        try {
          await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(broadcast.streamUrl)));
          loaded = true;
        } catch (e2) {
          final err = _formatError(e2);
          _lastError = err;
          emit(state.copyWith(
            error: 'فشل تشغيل البث: $err',
            isPlaying: false,
            isLoading: false,
          ));
          _isChanging = false;
          return;
        }
      }

      if (loaded) {
        await _audioPlayer.play();
        emit(state.copyWith(
          currentBroadcast: broadcast,
          isPlaying: true,
          isLoading: false,
          error: null,
        ));
        _lastError = null;
      }
    } catch (e) {
      final err = _formatError(e);
      _lastError = err;
      emit(state.copyWith(
        error: 'فشل تشغيل البث: $err',
        isPlaying: false,
        isLoading: false,
      ));
    } finally {
      _isChanging = false;
    }
  }

  Future<void> pause() async {
    if (_isChanging) return;
    try {
      await _audioPlayer.pause();
      emit(state.copyWith(isPlaying: false, error: null));
      _lastError = null;
    } catch (e) {
      final err = _formatError(e);
      _lastError = err;
      emit(state.copyWith(error: 'فشل في إيقاف البث مؤقتاً: $err'));
    }
  }

  Future<void> stop() async {
    if (_isChanging) return;
    try {
      await _audioPlayer.stop();
      _currentBroadcast = null;
      emit(state.copyWith(
        currentBroadcast: null,
        isPlaying: false,
        error: null,
      ));
      _lastError = null;
    } catch (e) {
      final err = _formatError(e);
      _lastError = err;
      emit(state.copyWith(error: 'فشل في إيقاف البث: $err'));
    }
  }

  @override
  Future<void> close() async {
    try {
      await _audioPlayer.dispose();
    } catch (_) {}
    return super.close();
  }
}