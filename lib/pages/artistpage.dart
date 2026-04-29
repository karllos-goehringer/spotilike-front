import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../class/artista_banda.dart';
import 'album.dart';
import '../controller/controller_album.dart';

class ArtistPage extends StatefulWidget {
  final ArtistaBanda artista;

  const ArtistPage({super.key, required this.artista});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late ArtistaBanda _currentArtista;
  bool _isLoadingAlbums = true;

  @override
  void initState() {
    super.initState();
    _currentArtista = widget.artista; // Inicializa com o artista passado
    _loadAlbumsIfNeeded();
  }

  Future<void> _loadAlbumsIfNeeded() async {
    // Verifica se os álbuns já estão carregados ou se precisamos buscá-los
    if (_currentArtista.albums == null || _currentArtista.albums!.isEmpty) {
      setState(() {
        _isLoadingAlbums = true;
      });
      final albums = await ControllerAlbum.getAlbumsByBandId(
          _currentArtista.id, _currentArtista.typeBand, _currentArtista.name);
      if (mounted) {
        setState(() {
          _currentArtista = _currentArtista.copyWith(albums: albums); // Cria uma nova instância com os álbuns atualizados
          _isLoadingAlbums = false;
        });
      }
    } else {
      setState(() {
        _isLoadingAlbums = false;
      });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com Imagem de Fundo e Perfil
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Imagem de Fundo
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                    ),
                    child: FutureBuilder<Uint8List?>(
                      future: ControllerAlbum.getAlbumArt(_currentArtista.backgroundImage),
                      builder: (context, snapshot) { // Usa widget.artista para propriedades estáticas
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }
                        return const Icon(Icons.image, color: Colors.white24, size: 50);
                      },
                    ),
                  ),
                  // Overlay de gradiente para suavizar a imagem de fundo
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          const Color.fromARGB(255, 47, 46, 48).withValues(alpha:0.8),
                        ],
                      ),
                    ),
                  ),
                  // Imagem de Perfil
                  Positioned(
                    bottom: -50,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 19, 19),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[800],
                        child: FutureBuilder<Uint8List?>(
                          future: ControllerAlbum.getAlbumArt(_currentArtista.imageUrl),
                          builder: (context, snapshot) { // Usa widget.artista para propriedades estáticas
                            if (snapshot.hasData && snapshot.data != null) {
                              return ClipOval(
                                child: Image.memory(
                                  snapshot.data!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return const Icon(Icons.person, size: 60, color: Colors.white54);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Informações do Artista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // Usa _currentArtista para exibição
                    Text(
                      _currentArtista.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_currentArtista.description != null && _currentArtista.description!.isNotEmpty)
                      Text( // Usa _currentArtista para propriedades estáticas
                        _currentArtista.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      'Álbuns',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de Álbuns
                    _isLoadingAlbums
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Colors.greenAccent),
                            ),
                          )
                        : (_currentArtista.albums == null || _currentArtista.albums!.isEmpty)
                            ? const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Nenhum álbum encontrado.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _currentArtista.albums!.length,
                                itemBuilder: (context, index) {
                                  final album = _currentArtista.albums![index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: FutureBuilder<Uint8List?>(
                                        future: ControllerAlbum.getAlbumArt(album.artUri),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return Image.memory(
                                              snapshot.data!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[900],
                                            child: const Icon(Icons.music_note, color: Colors.white54),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      album.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(album.artist, style: const TextStyle(color: Colors.white54)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AlbumPage(albumId: album.albumid)),
                                      );
                                    },
                                  );
                                },
                              ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
