import 'package:flutter/material.dart';
import '../class/playlist.dart';
import '../class/song.dart'; // Certifique-se de importar a classe Song

class PlaylistPage extends StatefulWidget {
  final Playlist playlist; 
  const PlaylistPage({super.key, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  
  // Função para lidar com o clique na música
  void _onSongTap(Song song) {
    // Aqui você chamaria seu player de áudio
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
      body: Container(
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
          children: [
            // --- CABEÇALHO ---
            const SizedBox(height: kToolbarHeight + 40),
            
            // Imagem Centralizada
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.playlist.imageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // Título e Botão de Play (Um em cada canto)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título da Playlist
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.playlist.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          "Playlist oficial", // Ou widget.playlist.description
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão de Play Circular
                  GestureDetector(
                    onTap: () => _onSongTap(widget.playlist.songs.first),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.greenAccent,
                      child: Icon(Icons.play_arrow, color: Colors.black, size: 35),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // --- LISTA DE MÚSICAS ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0, bottom: 20),
                itemCount: widget.playlist.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.playlist.songs[index];
                  
                  // InkWell torna toda a linha clicável com efeito visual
                  return InkWell(
                    onTap: () => _onSongTap(song),
                    splashColor: Colors.white10,
                    highlightColor: Colors.white12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // 1. Posição
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          ),
                          
                          // 2. Imagem do Álbum
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              song.albumImg,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // 3. Informações
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
                          
                          // 4. Duração e Menu
                          Text(
                            song.duration,
                            style: const TextStyle(color: Colors.white54, fontSize: 14),
                          ),
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
  }
}