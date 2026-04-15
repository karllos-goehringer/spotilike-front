import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}
Widget _buildMediaDisplay({
  required String title,
  required String artist,
  required String artUri,
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
          child: Image.asset(
            'images/vanhalen.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Erro ao carregar imagem: $error');
              return const Icon(Icons.music_note, size: 100, color: Colors.white);
            },
          ),
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
final mediaItem = MediaItem(
  id: '1',
  album: 'Van Halen',
  title: 'I’m the One',
  artist: 'Van Halen',
  duration: const Duration(minutes: 3, seconds: 45),
  artUri: Uri.parse('assets/images/vanhalen.jpg'),
);
class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _showVolumeSlider = false;
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds".replaceFirst(RegExp(r'^0:'), '');
  }
  
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );
  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }
  Future<void> _initializeAudio() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setAsset('music/musica.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 47, 46, 48),
                const Color.fromARGB(255, 22, 19, 19),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // 1. Metadata Widget (You must build this yourself to show the title/artist)
    _buildMediaDisplay(
    title: mediaItem.title,
    artist: mediaItem.artist ?? 'Unknown Artist',
    artUri: mediaItem.artUri.toString(),
  ),
    
    const SizedBox(height: 20),

    // 2. The Progress Bar
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: StreamBuilder<PositionData>(
        stream: _positionDataStream, // Assumes a combined stream of position/buffered/total
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          
          return ProgressBar(
            progress: positionData?.position ?? Duration.zero,
            buffered: positionData?.bufferedPosition ?? Duration.zero,
            total: positionData?.duration ?? Duration.zero,
            onSeek: (duration) {
              _audioPlayer.seek(duration);
            },
            // Styling
            barHeight: 5.0,
            baseBarColor: Colors.grey.withOpacity(0.2),
            bufferedBarColor: Colors.grey.withOpacity(0.4),
            progressBarColor: Colors.greenAccent,
            thumbColor: Colors.greenAccent,
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
              _formatDuration(positionData?.position ?? Duration.zero),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 8),
            const Text(
              '/',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(positionData?.duration ?? Duration.zero),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              const Icon(Icons.volume_down, color: Colors.white70, size: 24),
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
                  inactiveColor: Colors.grey.withOpacity(0.3),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.volume_up, color: Colors.white70, size: 24),
            ],
          ),
        );
      },
    ),

    const SizedBox(height: 20),

    // 3. Playback Controls
    Controls(audioPlayer: _audioPlayer),
  ],
)
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({Key? key, required this.audioPlayer}) : super(key: key);
  final AudioPlayer audioPlayer;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 64.0,
            height: 64.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 64.0,
            onPressed: audioPlayer.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: Icon(Icons.pause),
            iconSize: 64.0,
            onPressed: audioPlayer.pause,
          );
        } else {
          return IconButton(
            icon: Icon(Icons.replay),
            iconSize: 64.0,
            onPressed: () async {
              try {
                // Para o player completamente
                await audioPlayer.stop();
                // Reinicializa o áudio
                await audioPlayer.setAsset('music/musica.mp3');
                // Começa a tocar
                await audioPlayer.play();
              } catch (e) {
                print('Erro ao fazer replay: $e');
                // Fallback: apenas tenta play
                try {
                  await audioPlayer.play();
                } catch (e2) {
                  print('Erro no fallback: $e2');
                }
              }
            },
          );
        }
      },
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}
