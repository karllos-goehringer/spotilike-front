import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../class/song.dart';
import '../controller/queue_manager.dart';
import '../controller/controller_music.dart';
import '../controller/controller_album.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

class MusicPlayerPage extends StatefulWidget {
  final List<Song> songs;
  final int initialIndex;
  final String albumTitle;
  final String albumArtist;
  final String albumArtUri;
  const MusicPlayerPage({
    super.key,
    required this.songs,
    this.initialIndex = 0,
    required this.albumTitle,
    required this.albumArtist,
    required this.albumArtUri,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  Uint8List? _currentArtBytes;
  
  // Getters para facilitar o acesso à instância global
  AudioPlayer get _audioPlayer => MusicController.player;
  QueueManager get _queueManager => MusicController.queueManager!;

  @override
  void initState() {
    super.initState();
    
    // Se for uma nova lista de músicas ou nada estiver tocando, inicializa
    if (MusicController.queueManager == null || 
        _isNewPlaylist(widget.songs)) {
      MusicController.queueManager = QueueManager.fromSongs(widget.songs);
      MusicController.queueManager!.jumpToIndex(widget.initialIndex);
      MusicController.currentAlbumTitle = widget.albumTitle;
      MusicController.currentAlbumArtUri = widget.albumArtUri;
      _initializeAudio();
    }
    
    _loadCurrentSongArt();
  }

  bool _isNewPlaylist(List<Song> newSongs) {
    if (MusicController.queueManager == null) return true;
    if (newSongs.length != MusicController.queueManager!.queue.length) return true;
    return newSongs.first.id != MusicController.queueManager!.queue.first.id;
  }

  @override
  void dispose() {
    // Removido o dispose para manter a música tocando globalmente
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        .replaceFirst(RegExp(r'^0:'), '');
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  Future<void> _initializeAudio() async {
    if (_queueManager.currentSong != null) {
      await MusicController.loadSong(_queueManager.currentSong!);
    }
  }

  Future<void> _loadCurrentSongArt() async {
    final song = _queueManager.currentSong;
    
    // Define qual URI usar: a da música ou a do álbum (fallback)
    final artPath = (song != null && song.albumImg.isNotEmpty) 
        ? song.albumImg 
        : (MusicController.currentAlbumArtUri ?? '');

    if (artPath.isNotEmpty) {
      if (mounted) setState(() => _currentArtBytes = null); // Limpa imagem anterior
      
      final bytes = await ControllerAlbum.getAlbumArt(artPath);
      if (mounted) {
        setState(() {
          _currentArtBytes = bytes;
        });
      }
    }
  }

  Future<void> _loadNextSong() async {
    await MusicController.playNext();
    if (mounted) {
      setState(() {});
      _loadCurrentSongArt();
    }
  }

  Future<void> _loadPreviousSong() async {
    await MusicController.playPrevious();
    if (mounted) {
      setState(() {});
      _loadCurrentSongArt();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 47, 46, 48),
                Color.fromARGB(255, 22, 19, 19),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Metadata Widget
              _buildMediaDisplay(
                title: _queueManager.currentSong?.title ?? 'Desconhecida',
                artist: _queueManager.currentSong?.band ?? _queueManager.currentSong?.artistName ?? 'Artista desconhecido',
                artBytes: _currentArtBytes,
              ),

              const SizedBox(height: 20),

              // 2. The Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;

                    return ProgressBar(
                      progress: positionData?.position ?? Duration.zero,
                      buffered: positionData?.bufferedPosition ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      onSeek: (duration) async {
                        await _audioPlayer.seek(duration);
                      },
                      thumbRadius: 8.0,
                      thumbColor: Colors.greenAccent,
                      thumbGlowRadius: 12.0,
                      thumbGlowColor: Colors.white,
                      barHeight: 5.0,
                      baseBarColor: Colors.grey.withValues(alpha:0.2),
                      bufferedBarColor: Colors.grey.withValues(alpha:0.4),
                      progressBarColor: Colors.greenAccent,
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Tempo atual / Total
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(
                            positionData?.position ?? Duration.zero),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(
                            positionData?.duration ?? Duration.zero),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Controle de Volume
              StreamBuilder<double>(
                stream: _audioPlayer.volumeStream,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_down,
                            color: Colors.white70, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: snapshot.data ?? 1.0,
                            min: 0,
                            max: 1,
                            onChanged: (value) {
                              _audioPlayer.setVolume(value);
                            },
                            activeColor: Colors.greenAccent,
                            inactiveColor: Colors.grey.withValues(alpha:0.3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.volume_up,
                            color: Colors.white70, size: 24),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 3. Playback Controls
              Controls(
                audioPlayer: _audioPlayer,
                onNext: _loadNextSong,
                onPrevious: _loadPreviousSong,
                queueManager: _queueManager,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaDisplay({
    required String title,
    required String artist,
    Uint8List? artBytes,
  }) {
    return Column(
      children: [
        // Album Art
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 300,
            height: 300,
            color: Colors.grey[800],
            child: artBytes != null
                ? Image.memory(
                    artBytes,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.music_note, size: 100, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Artist
        Text(
          artist,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.audioPlayer,
    required this.onNext,
    required this.onPrevious,
    required this.queueManager,
  });

  final AudioPlayer audioPlayer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final QueueManager queueManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão anterior
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 48.0,
          color: Colors.white70,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 20),
        // Botão play/pausa
        StreamBuilder<PlayerState>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const SizedBox(
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(
                  color: Colors.greenAccent,
                ),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                color: Colors.greenAccent,
                onPressed: audioPlayer.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                color: Colors.greenAccent,
                onPressed: audioPlayer.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                color: Colors.greenAccent,
                onPressed: () async {
                  try {
                    await audioPlayer.seek(Duration.zero);
                    await audioPlayer.play();
                  } catch (e) {
                    dev.log('Erro ao fazer replay: $e');
                  }
                },
              );
            }
          },
        ),
        const SizedBox(width: 20),
        // Botão próximo
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 48.0,
          color: Colors.white70,
          onPressed: onNext,
        ),
      ],
    );
  }
}
