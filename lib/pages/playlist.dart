import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../class/playlist.dart';
import '../class/song.dart';
import '../controller/controller_album.dart';
import '../controller/controller_playlist.dart';
import 'music_player.dart';

class PlaylistPage extends StatefulWidget {
  final int playlistId;
  const PlaylistPage({super.key, required this.playlistId});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Future<Playlist?> _playlistFuture;
  Future<Uint8List?>? _artFuture;

  @override
  void initState() {
    super.initState();
    _playlistFuture = _initPlaylist();
  }

  Future<Playlist?> _initPlaylist() async {
    final playlist = await PlaylistController.getPlaylist(widget.playlistId);
    if (playlist != null && playlist.imageUrl != null) {
      setState(() {
        _artFuture = ControllerAlbum.getAlbumArt(playlist.imageUrl!.toString() ?? '');
      });
    }
    return playlist;
  }

  void _playSong(Song song, Playlist playlist) {
    final songIndex = playlist.songs.indexOf(song);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(
          songs: playlist.songs,
          initialIndex: songIndex,
          albumTitle: playlist.name,
          albumArtist: playlist.name,
          albumArtUri: playlist.imageUrl ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Playlist?>(
      future: _playlistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
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
              child: const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Container(
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      'Erro ao carregar playlist',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final playlist = snapshot.data!;

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
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
              children: [
                const SizedBox(height: kToolbarHeight + 40),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FutureBuilder<Uint8List?>(
                      future: _artFuture,
                      builder: (context, artSnapshot) {
                        if (artSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.greenAccent),
                            ),
                          );
                        }

                        if (artSnapshot.hasData && artSnapshot.data != null) {
                          return Image.memory(
                            artSnapshot.data!,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          );
                        }

                        return Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[900],
                          child: const Icon(Icons.music_note, size: 100, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              playlist.description ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: playlist.songs.isNotEmpty
                              ? () => _playSong(playlist.songs.first, playlist)
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Icon(Icons.play_arrow, size: 40, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 20),
                    itemCount: playlist.songs.length,
                    itemBuilder: (context, index) {
                      final song = playlist.songs[index];
                      return InkWell(
                        onTap: () => _playSong(song, playlist),
                        splashColor: Colors.white10,
                        highlightColor: Colors.white12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: song.albumImg.isNotEmpty
                                    ? Image.network(
                                        song.albumImg,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return
                                          Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[900],
                                            child: const Icon(Icons.music_note, color: Colors.white54),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[900],
                                        child: const Icon(Icons.music_note, color: Colors.white54),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${song.band} • ${song.album}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              const SizedBox(width: 12),
                              const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
