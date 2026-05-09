import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import '../controller/controller_music.dart';
import '../controller/controller_album.dart';
import 'music_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças no estado do player e na sequência (troca de música)
    return StreamBuilder<SequenceState?>(
      stream: MusicController.player.sequenceStateStream,
      builder: (context, snapshot) {
        final sequenceState = snapshot.data;
        if (sequenceState?.currentSource == null || MusicController.queueManager == null) {
          return const SizedBox.shrink();
        }

        final currentSong = MusicController.queueManager?.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(
                  songs: MusicController.queueManager!.queue,
                  albumTitle: MusicController.currentAlbumTitle ?? '',
                  albumArtist: currentSong.band,
                  albumArtUri: MusicController.currentAlbumArtUri ?? '',
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            height: 70,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 35, 35, 35),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                // Capa Pequena
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[800],
                      child: (currentSong.albumImg.isNotEmpty || (MusicController.currentAlbumArtUri?.isNotEmpty ?? false))
                          ? FutureBuilder<Uint8List?>(
                              future: ControllerAlbum.getAlbumArt(
                                currentSong.albumImg.isNotEmpty 
                                  ? currentSong.albumImg 
                                  : MusicController.currentAlbumArtUri!
                              ),
                              builder: (context, artSnapshot) {
                                if (artSnapshot.hasData && artSnapshot.data != null) {
                                  return Image.memory(
                                    artSnapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Icon(Icons.music_note, color: Colors.white54, size: 20);
                              },
                            )
                          : const Icon(Icons.music_note, color: Colors.white54),
                    ),
                  ),
                ),
                // Título e Artista
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.band,
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Controles
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () => MusicController.playPrevious(),
                ),
                StreamBuilder<bool>(
                  stream: MusicController.player.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          MusicController.player.pause();
                        } else {
                          MusicController.player.play();
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () => MusicController.playNext(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}