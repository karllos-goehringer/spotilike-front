import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../class/playlist.dart';
import '../controller/controller_playlist.dart';
import '../class/api_params.dart';
import 'playlist.dart';

class BibliotecaPage extends StatefulWidget {
  @override
  _BibliotecaPageState createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  List<Playlist> playlists = [];
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    const int userID = 2; // Use o ID que veio do login: {"id":2}
    final result = await PlaylistController.getAllPlaylistUser(userID);
    if (result != null) {
      setState(() {
        playlists = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Tratar erro, exibir snackbar ou algo
    }
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Criar Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Playlist',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),

                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                },
                child: const Text('Selecionar Imagem'),
              ),
              if (selectedImage != null) ...[
                const SizedBox(height: 8),
                Image.file(File(selectedImage!.path), height: 100, width: 100, fit: BoxFit.cover),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nameController.clear();
                _descriptionController.clear();
                setState(() {
                  selectedImage = null;
                });
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final description = _descriptionController.text.trim();
                if (name.isNotEmpty) {
                  const int userID = 1; // Placeholder
                  final newPlaylist = await PlaylistController.createPlaylist(
                    userID: userID,
                    name: name,
                    description: description,
                    image: selectedImage,
                  );
                  if (newPlaylist != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist criada com sucesso!')),
                    );
                    await _loadPlaylists();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao criar playlist.')),
                    );
                  }
                }
                Navigator.of(context).pop();
                _nameController.clear();
                _descriptionController.clear();
                setState(() {
                  selectedImage = null;
                });
              },
              child: const Text(
                'Criar',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight + 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Biblioteca',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio: 0.82, 
                      ),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistPage(playlistId: playlist.id),
                              ),
                            );
                            if (result == true) {
                              _loadPlaylists();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Colors.white12, width: 1),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.grey[900],
                                      child: playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              playlist.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.music_note, color: Colors.white54),
                                            )
                                          : const Center(
                                              child: Icon(Icons.music_note,
                                                  color: Colors.white54, size: 40),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  playlist.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}