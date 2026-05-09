import 'dart:typed_data';
import '../class/user.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:spotilike_front/pages/login.dart';
import 'package:spotilike_front/controller/controller_user.dart';
import 'package:spotilike_front/pages/perfil_page.dart';
import '../class/album.dart';
import 'dart:ui';
import '../class/artista_banda.dart';
import '../controller/controller_album.dart';
import '../controller/controller_artistabanda.dart';
import 'album.dart';
import 'artistpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Album> albums = [];
  List<ArtistaBanda> artists = [];
  List<ArtistaBanda> bands = [];
  bool isLoading = true;
  // ValueNotifier para rastrear a página atual do carrossel de álbuns
  final ValueNotifier<int> _currentAlbumPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _currentAlbumPageNotifier
        .dispose(); // Dispose do notifier para evitar vazamentos de memória
    super.dispose();
  }

  Future<void> _loadData() async {
    final albumsResult = await ControllerAlbum.getAllAlbums();
    final artistsResult = await ControlleArtistabanda.getAllArtists();
    final bandsResult = await ControlleArtistabanda.getAllBands();
    if (mounted) {
      setState(() {
        albums = albumsResult ?? [];
        artists = artistsResult;
        bands = bandsResult;
        isLoading = false;
      });
    }
  }

  Future<void> _goToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserPage(user: ControllerUser.currentUser!)),
    );
    _loadData(); // Recarrega os dados (incluindo o estado do usuário e listas) ao retornar
  }

  void _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        content: const Text('Deseja realmente fazer logoff?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ControllerUser.logout();
      if (mounted)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: kToolbarHeight + 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Boas Vindas!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<String>(
                          offset: const Offset(100, 50),
                          color: const Color.fromARGB(255, 45, 45, 45),
                          onSelected: (value) {
                            if (value == 'perfil') _goToProfile();
                            if (value == 'logout') _handleLogout();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'perfil',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.white70),
                                  SizedBox(
                                    width: 12,
                                  ), 
                                  Text(
                                    'Meu Perfil',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, color: Colors.redAccent),
                                  SizedBox(
                                    width: 12,
                                  ), // Adds some breathing room between the icon and text
                                  Text(
                                    'Sair',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[800],
                              child: FutureBuilder<Uint8List?>(
                                future:
                                    ControllerUser.currentUser != null &&
                                        ControllerUser
                                                .currentUser!
                                                .profileImageUrl !=
                                            null
                                    ? ControllerUser.getProfileImageUrl()
                                    : Future.value(null),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return ClipOval(
                                      child: Image.memory(
                                        snapshot.data!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                  return const Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.white54,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Álbuns em destaque',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 250,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        autoPlay: false,
                        viewportFraction:
                            0.5, // Ajusta para mostrar 3 álbuns, com o central maior
                        onPageChanged: (index, reason) {
                          _currentAlbumPageNotifier.value = index;
                        },
                      ),
                      items: List.generate(albums.length, (index) {
                        // Usamos List.generate para ter acesso ao índice
                        final album = albums[index];
                        return ValueListenableBuilder<int>(
                          valueListenable: _currentAlbumPageNotifier,
                          builder: (context, currentPage, child) {
                            // Verifica se o item atual é o item central
                            final bool isCenter = index == currentPage;

                            Widget albumImageWidget = Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: album.artUri.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(album.artUri),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: album.artUri.isEmpty
                                    ? Colors.grey[900]
                                    : null,
                              ),
                              child: album.artUri.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Sem Imagem',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : null,
                            );

                            if (!isCenter) {
                              // Aplica desfoque aos itens que não são o central
                              albumImageWidget = ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 2.0,
                                  sigmaY: 2.0,
                                ), // Ajuste o sigma para o desfoque desejado
                                child: albumImageWidget,
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AlbumPage(albumId: album.albumid),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(child: albumImageWidget),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      album.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Artistas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        initialPage: 1,
                        viewportFraction: 0.35,
                      ),
                      items: artists.map((artist) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArtistPage(artista: artist),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[900],
                                backgroundImage: artist.imageUrl.isNotEmpty
                                    ? NetworkImage(artist.imageUrl)
                                    : null,
                                child: artist.imageUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                        size: 40,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                artist.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Bandas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        initialPage: 1,
                        viewportFraction: 0.35,
                      ),
                      items: bands.map((band) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistPage(artista: band),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[900],
                                backgroundImage: band.imageUrl.isNotEmpty
                                    ? NetworkImage(band.imageUrl)
                                    : null,
                                child: band.imageUrl.isEmpty
                                    ? const Icon(
                                        Icons.group,
                                        color: Colors.white54,
                                        size: 40,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                band.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}
