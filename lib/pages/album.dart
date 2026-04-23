import 'package:flutter/material.dart';
import '../class/album.dart';
import '../class/song.dart';


//final albumMock = Album(title: 'Van Halen', artist: 'Van Halen', artUri: 'images/vanhalen.jpg', songs: [
//  Song(id: 1, title: 'Runnin\' with the Devil', duration: '3:36', fileUri: 'assets/songs/runnin_with_the_devil.mp3', album: 'Van Halen'),
//  Song(id: 2, title: 'Eruption', duration: '1:42', fileUri: 'assets/songs/eruption.mp3', album: 'Van Halen'),
//  Song(id: 3, title: 'You Really Got Me', duration: '2:13', fileUri: 'assets/songs/you_really_got_me.mp3', album: 'Van Halen'),
//]);
Color _iconColor = Colors.white70; 
_setarAlbumFavorito() {
}

class AlbumPage extends StatefulWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  void _playSong(Song song) {
    // Integração futura com seu player
  }

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  widget.album.artUri,
                  width: 280,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(
                      width: 280, height: 280, 
                      color: Colors.grey[900], 
                      child: const Icon(Icons.music_note, size: 100, color: Colors.white)
                    ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título do Álbum
              Text(
                widget.album.title,
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
                widget.album.artist,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
  
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Ícone de Curtir
    IconButton(
  onPressed: () {
    setState(() {
      // Altera a cor
      if (_iconColor == Colors.white70) {
        _iconColor = Colors.greenAccent;
      } else {
        _iconColor = Colors.white70;
      }

    });
    
    // Chama sua função aqui
    _setarAlbumFavorito(); 
  },
  icon: Icon(
    Icons.favorite, 
    color: _iconColor, // A cor agora depende da variável
    size: 30
  ),
),

    // Botão de Play Circular
    SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _playSong(widget.album.songs.first),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black, // Cor do efeito de clique (ripple)
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
      icon: const Icon(Icons.more_vert, color: Colors.white70, size: 30),
    ),
  ],
),
              
              const SizedBox(height: 10),
              const Divider(color: Colors.white10),

              // Lista de Músicas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.album.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.album.songs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    onTap: () => _playSong(song),
                    tileColor: Colors.white10,
                    leading: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, 
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                    subtitle: Text(
                      widget.album.artist, 
                      style: const TextStyle(color: Colors.white54)
                    ),
                    trailing: const Icon(Icons.more_horiz, color: Colors.white54),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}