import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../class/playlist.dart';
import '../controller/controller_album.dart';
import '../controller/controller_playlist.dart';
import '../controller/controller_user.dart';
import 'package:spotilike_front/class/user.dart';
import 'playlist.dart';

class UserPage extends StatefulWidget {
  final User user;
  const UserPage({super.key, required this.user});
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late User _currentUser;
  bool _isLoadingPlaylists = true;
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; 
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final userPlaylists = await PlaylistController.getAllPlaylistUser(_currentUser.id);
    if (mounted) {
      setState(() {
        _playlists = userPlaylists ?? [];
        _isLoadingPlaylists = false;
      });
    }
  }

  Future<void> _showEditProfileDialog() async {
    final descController = TextEditingController(text: _currentUser.description);
    XFile? newProfileImage;
    XFile? newBackgroundImage;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) setDialogState(() => newProfileImage = image);
                  },
                  icon: const Icon(Icons.person),
                  label: Text(newProfileImage == null ? 'Foto de Perfil' : 'Selecionada'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) setDialogState(() => newBackgroundImage = image);
                  },
                  icon: const Icon(Icons.image),
                  label: Text(newBackgroundImage == null ? 'Imagem de Fundo' : 'Selecionada'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            isSaving 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent)
                )
              : TextButton(
                  onPressed: () async {
                    setDialogState(() => isSaving = true);
                    final success = await ControllerUser.updateProfile(
                      userID: _currentUser.id,
                      description: descController.text,
                      image: newProfileImage,
                      backgroundImage: newBackgroundImage,
                    );
                    
                    if (success) {
                      await ControllerUser.getUser(_currentUser.id);
                    }
                    
                    if (!mounted) return;
                    setDialogState(() => isSaving = false);
                    
                    if (success) {
                      setState(() => _currentUser = ControllerUser.currentUser!);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao atualizar. Verifique os logs.')),
                      );
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: Colors.greenAccent)),
                ),
          ],
        ),
      ),
    );
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
                      future: _currentUser.backgroundImage != null && _currentUser.backgroundImage!.isNotEmpty
                          ? ControllerAlbum.getAlbumArt(_currentUser.backgroundImage!)
                          : Future.value(null),
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
                  // Botão de Edição (Canto esquerdo da backgroundImage, abaixo do botão voltar)
                  Positioned(
                    top: kToolbarHeight + 10,
                    left: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _showEditProfileDialog,
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
                          future: _currentUser.profileImageUrl != null && _currentUser.profileImageUrl!.isNotEmpty
                              ? ControllerAlbum.getAlbumArt(_currentUser.profileImageUrl!)
                              : Future.value(null),
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

              // Informações do Usuário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    Text(
                      _currentUser.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_currentUser.description != null && _currentUser.description!.isNotEmpty)
                      Text( 
                        _currentUser.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      'Playlists',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de Playlists
                    _isLoadingPlaylists
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Colors.greenAccent),
                            ),
                          )
                        : _playlists.isEmpty
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
                                itemCount: _playlists.length,
                                itemBuilder: (context, index) {
                                  final playlist = _playlists[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              playlist.imageUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[900],
                                                child: const Icon(Icons.music_note, color: Colors.white54),
                                              ),
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[900],
                                              child: const Icon(Icons.music_note, color: Colors.white54),
                                            ),
                                    ),
                                    title: Text(
                                      playlist.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      playlist.description ?? '',
                                      style: const TextStyle(color: Colors.white54),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PlaylistPage(playlistId: playlist.id)),
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
