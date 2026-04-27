import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../class/album.dart';
import '../class/song.dart';
import '../controller/controller_album.dart';
import 'music_player.dart';

class AlbumPage extends StatefulWidget {
  final int albumId;
  const AlbumPage({super.key, required this.albumId});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late Future<Album?> _albumFuture;
  Future<Uint8List?>? _artFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _albumFuture = _initAlbum();
  }

  Future<Album?> _initAlbum() async {
    final album = await ControllerAlbum.getAlbumById(widget.albumId.toString());
    if (album != null && album.artUri.isNotEmpty) {
      // Criamos a future da arte apenas UMA VEZ aqui
      setState(() {
        _artFuture = ControllerAlbum.getAlbumArt(album.artUri);
      });
    }
    return album;
  }

  void _playSong(Song song, Album album) {
    // Encontrar o índice da música clicada
    int songIndex = album.songs.indexOf(song);
    
    // Navegar para o player com a fila de músicas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(
          songs: album.songs,
          initialIndex: songIndex,
          albumTitle: album.title,
          albumArtist: album.artist,
          albumArtUri: album.artUri,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Album?>(
      future: _albumFuture,
      builder: (context, snapshot) {
        // Carregando
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

        // Erro
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
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      'Erro ao carregar álbum',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final album = snapshot.data!;

        return Scaffold(
          // Estendemos o corpo para trás da AppBar para um visual imersivo
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: kToolbarHeight + 40),

                  // Capa do Álbum (estilo MusicPlayer)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FutureBuilder<Uint8List?>(
                      future: _artFuture,
                      builder: (context, artSnapshot) {
                        if (artSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 280,
                            height: 280,
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.greenAccent),
                            ),
                          );
                        }
                        if (artSnapshot.hasData && artSnapshot.data != null) {
                          return Image.memory(
                            artSnapshot.data!,
                            width: 280,
                            height: 280,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.grey[900],
                          child: const Icon(Icons.music_note,
                              size: 100, color: Colors.white),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título do Álbum
                  Text(
                    album.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Artista
                  Text(
                    album.artist,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //// Ícone de Curtir
                      //IconButton(
                      //  onPressed: _toggleFavorite,
                      //  icon: Icon(
                      //    _isFavorite ? Icons.favorite : Icons.favorite_outline,
                      //    color: _isFavorite ? Colors.redAccent :,album Colors.white70,
                      //    size: 30,
                      //  ),
                      //),

                      // Botão de Play Circular
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: album.songs.isNotEmpty
                              ? () => _playSong(album.songs.first, album)
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // Ícone de Menu/Mais
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white70, size: 30),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: Colors.white10),

                  // Lista de Músicas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: album.songs.length,
                    itemBuilder: (context, index) {
                      final song = album.songs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        onTap: () => _playSong(song, album),
                        tileColor: Colors.white10,
                        leading: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 16),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          album.artist,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(Icons.more_horiz,
                            color: Colors.white54),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}