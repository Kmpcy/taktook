import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qemam_task/Features/Broadcast/model/broadcast_model.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_cubit.dart';
import 'package:qemam_task/Features/Broadcast/view_model/broadcast%20cubit/broadcast_state.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({Key? key}) : super(key: key);

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  OverlayEntry? _floatingOverlay;
  bool _isOverlayInserted = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String? _lastShownError;

  void _insertOverlay(BuildContext pageContext) {
    final cubit = pageContext.read<BroadcastCubit>();

    if (_floatingOverlay == null || !_isOverlayInserted) {
      _floatingOverlay = OverlayEntry(
        builder: (_) {
          return BlocProvider.value(
            value: cubit,
            child: const FloatingControl(),
          );
        },
      );

      Overlay.of(pageContext)?.insert(_floatingOverlay!);
      _isOverlayInserted = true;
    }
  }

  void _removeOverlay() {
    if (_isOverlayInserted) {
      _floatingOverlay?.remove();
      _floatingOverlay = null;
      _isOverlayInserted = false;
    }
  }

  @override
  void dispose() {
    _floatingOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: BlocProvider(
        create: (_) => BroadcastCubit(),
        child: BlocConsumer<BroadcastCubit, BroadcastState>(
          listener: (ctx, state) {
            // إدارة الـ overlay للكرة العائمة
            if (state.currentBroadcast != null) {
              _insertOverlay(ctx);
            } else {
              _removeOverlay();
            }

            // إدارة رسائل الخطأ - عرضها مرة واحدة فقط
            if (state.error != null && state.error!.isNotEmpty && state.error != _lastShownError) {
              _lastShownError = state.error;
              _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(state.error!, textAlign: TextAlign.center),
                  backgroundColor: Colors.red[700],
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'حاول مرة أخرى',
                    textColor: Colors.white,
                    onPressed: () {
                      if (state.currentBroadcast != null) {
                        ctx.read<BroadcastCubit>().play(state.currentBroadcast!);
                      }
                    },
                  ),
                ),
              );
            } else if ((state.error == null || state.error!.isEmpty) && _lastShownError != null) {
              _lastShownError = null;
              _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            }
          },
          builder: (ctx, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('البث المباشر'),
                backgroundColor: Colors.blue,
              ),
              body: _BroadcastList(),
              bottomNavigationBar: const _MiniPlayer(),
            );
          },
        ),
      ),
    );
  }
}

class _BroadcastList extends StatelessWidget {
  const _BroadcastList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      buildWhen: (previous, current) {
        // إعادة البناء فقط عند تغيير ضروري
        return previous.currentBroadcast?.id != current.currentBroadcast?.id ||
               previous.isLoading != current.isLoading ||
               previous.isPlaying != current.isPlaying ||
               previous.error != current.error;
      },
      builder: (ctx, state) {
        final list = state.broadcasts;
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (c, idx) {
            final item = list[idx];
            final isCurrent = state.currentBroadcast?.id == item.id;

            return _BroadcastListItem(
              broadcast: item,
              isCurrent: isCurrent,
              state: state,
            );
          },
        );
      },
    );
  }
}

class _BroadcastListItem extends StatelessWidget {
  final Broadcast broadcast;
  final bool isCurrent;
  final BroadcastState state;

  const _BroadcastListItem({
    Key? key,
    required this.broadcast,
    required this.isCurrent,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.radio, color: Colors.blue),
        title: Text(
          broadcast.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isCurrent
              ? (state.isLoading
                  ? 'جاري التحميل...'
                  : (state.isPlaying ? 'جاري التشغيل' : 'متوقف مؤقتاً'))
              : 'اضغط للاستماع',
        ),
        trailing: _getTrailingIcon(state, isCurrent),
        onTap: () {
          final cubit = context.read<BroadcastCubit>();
          if (isCurrent && state.isPlaying) {
            cubit.pause();
          } else {
            cubit.play(broadcast);
          }
        },
      ),
    );
  }

  Widget _getTrailingIcon(BroadcastState state, bool isCurrent) {
    if (isCurrent && state.isLoading) {
      return const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    } else if (isCurrent && state.isPlaying) {
      return const Icon(Icons.pause_circle_filled, color: Colors.green, size: 30);
    } else {
      return const Icon(Icons.play_circle_filled, color: Colors.blue, size: 30);
    }
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      buildWhen: (previous, current) {
        return previous.currentBroadcast?.id != current.currentBroadcast?.id ||
               previous.isLoading != current.isLoading ||
               previous.isPlaying != current.isPlaying;
      },
      builder: (ctx, state) {
        if (state.currentBroadcast == null) return const SizedBox.shrink();

        return Container(
          height: 64,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.radio, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentBroadcast!.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      state.isLoading
                          ? 'جاري التحميل...'
                          : (state.isPlaying ? 'جاري التشغيل' : 'متوقف مؤقتاً'),
                      style: TextStyle(
                        color: state.isLoading
                            ? Colors.blue
                            : (state.isPlaying ? Colors.green : Colors.orange),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isLoading)
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    final cubit = context.read<BroadcastCubit>();
                    if (state.isPlaying) {
                      cubit.pause();
                    } else if (state.currentBroadcast != null) {
                      cubit.play(state.currentBroadcast!);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class FloatingControl extends StatefulWidget {
  const FloatingControl({super.key});

  @override
  State<FloatingControl> createState() => _FloatingControlState();
}

class _FloatingControlState extends State<FloatingControl> {
  Offset position = const Offset(20, 120);
  final double ballSize = 70.0;
  bool _dragging = false;

  Offset _snapToEdge(Offset offset, BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    double x = offset.dx;
    double y = offset.dy;

    if (x < w / 2) {
      x = 20;
    } else {
      x = w - ballSize - 20;
    }
    y = y.clamp(80.0, h - ballSize - 80.0);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BroadcastCubit, BroadcastState>(
      buildWhen: (previous, current) {
        return previous.currentBroadcast?.id != current.currentBroadcast?.id ||
               previous.isLoading != current.isLoading ||
               previous.isPlaying != current.isPlaying;
      },
      builder: (ctx, state) {
        if (state.currentBroadcast == null) return const SizedBox.shrink();

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanStart: (_) => setState(() => _dragging = true),
            onPanUpdate: (d) {
              setState(() {
                position = Offset(
                  (position.dx + d.delta.dx)
                      .clamp(0.0, MediaQuery.of(context).size.width - ballSize),
                  (position.dy + d.delta.dy)
                      .clamp(0.0, MediaQuery.of(context).size.height - ballSize - 100),
                );
              });
            },
            onPanEnd: (_) {
              setState(() {
                _dragging = false;
                position = _snapToEdge(position, context);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dragging ? Colors.blue[700] : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: state.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        final cubit = context.read<BroadcastCubit>();
                        if (state.isPlaying) {
                          cubit.pause();
                        } else if (state.currentBroadcast != null) {
                          cubit.play(state.currentBroadcast!);
                        }
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}