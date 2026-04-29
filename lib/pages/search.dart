import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../controller/controller_busca.dart';
import '../controller/controller_album.dart';
import '../class/album.dart';
import '../class/artista_banda.dart';
import '../class/song.dart';
import '../controller/controller_playlist.dart';
import '../class/playlist.dart';
import 'album.dart';
import 'artistpage.dart';
import 'music_player.dart';
import 'dart:developer' as dev;
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Album> _albums = [];
  List<ArtistaBanda> _artists = [];
  List<ArtistaBanda> _bands = [];
  List<Song> _songs = [];
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _albums = [];
        _artists = [];
        _bands = [];
        _songs = [];
        _playlists = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ControllerBusca.search(query);
      if (!mounted) return;
      setState(() {
        _albums = (results['albums'] ?? []).map((json) => Album.fromJson(json)).toList();
        _artists = (results['artists'] ?? []).map((json) => ArtistaBanda.fromJson(json)).toList();
        _bands = (results['bands'] ?? []).map((json) => ArtistaBanda.fromJson(json)).toList();
        _songs = (results['songs'] ?? []).map((json) => Song.fromJson(json)).toList();
        _playlists = (results['playlists'] ?? []).map((json) => Playlist.fromJson(json, [])).toList();
      });
    } catch (e) {
      dev.log("Erro na pesquisa: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPlaylistSelectionDialog(Song song) {
    showDialog(
      context: context,
      builder: (context) {
        const int userID = 2; // ID placeholder, mantendo o padrão do seu projeto
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Adicionar à Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<Playlist>?>(
              future: PlaylistController.getAllPlaylistUser(userID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhuma playlist encontrada.', style: TextStyle(color: Colors.white70));
                }
                final playlists = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.playlist_add, color: Colors.greenAccent),
                      title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                      onTap: () async {
                        final success = await PlaylistController.addSongPlaylist(
                          playlist.id,
                          int.parse(song.id),
                          playlist.length
                        );
                        if (!mounted) return;

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                              ? 'Música adicionada a "${playlist.name}"!' 
                              : 'Erro ao adicionar música.'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                const SizedBox(height: 5),
                const Text(
                  'Pesquisar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Caixa de Pesquisa
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "O que você quer ouvir?",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (value) {
                    _performSearch(value);
                  },
                ),
                const SizedBox(height: 20),
                // Resultados da Pesquisa
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                      : _albums.isEmpty && _artists.isEmpty && _bands.isEmpty && _songs.isEmpty && _playlists.isEmpty
                          ? const Center(
                              child: Text(
                                "Busque por artistas, músicas ou álbuns",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                if (_artists.isNotEmpty) ...[
                                  _buildSectionTitle('Artistas'),
                                  ..._artists.map((artist) => _buildArtistTile(artist)),
                                ],
                                if (_bands.isNotEmpty) ...[
                                  _buildSectionTitle('Bandas'),
                                  ..._bands.map((band) => _buildArtistTile(band)),
                                ],
                                if (_songs.isNotEmpty) ...[
                                  _buildSectionTitle('Músicas'),
                                  ..._songs.map((song) => _buildSongTile(song)),
                                ],
                                if (_playlists.isNotEmpty) ...[
                                  _buildSectionTitle('Playlists'),
                                  ..._playlists.map((playlist) => _buildPlaylistTile(playlist)),
                                ],
                                if (_albums.isNotEmpty) ...[
                                  _buildSectionTitle('Álbuns'),
                                  ..._albums.map((album) => _buildAlbumTile(album)),
                                ],
                                const SizedBox(height: 20),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildArtistTile(ArtistaBanda artist) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistPage(artista: artist))),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[900],
        child: FutureBuilder<Uint8List?>(
          future: ControllerAlbum.getAlbumArt(artist.imageUrl),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ClipOval(child: Image.memory(snapshot.data!, width: 60, height: 60, fit: BoxFit.cover));
            }
            return const Icon(Icons.person, color: Colors.white54);
          },
        ),
      ),
      title: Text(artist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: const Text('Artista', style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _buildAlbumTile(Album album) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPage(albumId: album.albumid))),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 60,
          height: 60,
          color: Colors.grey[900],
          child: FutureBuilder<Uint8List?>(
            future: ControllerAlbum.getAlbumArt(album.artUri),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return const Icon(Icons.album, color: Colors.white54);
            },
          ),
        ),
      ),
      title: Text(album.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(album.artist, style: const TextStyle(color: Colors.white54)),
    );
  }

  Widget _buildSongTile(Song song) {
    return ListTile(
      onTap: () {
        final songIndex = _songs.indexOf(song);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerPage(
              songs: _songs,
              initialIndex: songIndex,
              albumTitle: (song.albumName != null && song.albumName!.isNotEmpty) ? song.albumName! : song.album,
              albumArtist: (song.artistName != null && song.artistName!.isNotEmpty) ? song.artistName! : song.band,
              albumArtUri: song.albumImg,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 50,
          height: 50,
          color: Colors.grey[900],
          child: FutureBuilder<Uint8List?>(
            future: ControllerAlbum.getAlbumArt(song.albumImg),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return const Icon(Icons.music_note, color: Colors.white54);
            },
          ),
        ),
      ),
      title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text('${song.artistName} • ${song.albumName}', style: const TextStyle(color: Colors.white54)),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white54),
        color: Colors.grey[900],
        onSelected: (value) {
          if (value == 'add_to_playlist') {
            _showPlaylistSelectionDialog(song);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'add_to_playlist',
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Adicionar à playlist',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return ListTile(
      onTap: () {
        // Lógica para abrir a página de detalhes da playlist
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 50,
          height: 50,
          color: Colors.grey[900],
          child: FutureBuilder<Uint8List?>(
            future: ControllerAlbum.getAlbumArt(playlist.imageUrl ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return const Icon(Icons.playlist_play, color: Colors.white54);
            },
          ),
        ),
      ),
      title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: const Text('Playlist', style: TextStyle(color: Colors.white54)),
    );
  }
}