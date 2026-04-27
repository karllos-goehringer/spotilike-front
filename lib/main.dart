import 'package:flutter/material.dart';
import 'pages/music_player.dart';
import 'pages/album.dart';
import '../class/album.dart';
import '../class/song.dart';
import '../class/api_params.dart';
import 'pages/playlist.dart';
import 'test/authentication_test_screen.dart';

void main() {
  runApp(const MainApp());
}
//final albumMock = Album(title: 'Van Halen', artist: 'Van Halen', artUri: 'images/vanhalen.jpg', songs: [
//  Song(id: 1, title: 'Runnin\' with the Devil', duration: '3:36', fileUri: 'assets/songs/runnin_with_the_devil.mp3', album: 'Van Halen'),
//  Song(id: 2, title: 'Eruption', duration: '1:42', fileUri: 'assets/songs/eruption.mp3', album: 'Van Halen'),
//  Song(id: 3, title: 'You Really Got Me', duration: '2:13', fileUri: 'assets/songs/you_really_got_me.mp3', album: 'Van Halen'),
//]);
//final mockSongs = [
//      Song(
//        id: 1,
//        band: 'Van Halen',
//        title: 'I’m the One',
//        duration: '03:45',
//        albumImg: 'images/vanhalen.jpg',
//        fileUri: 'music/musica1.mp3',
//        album: 'Van Halen',
//      ),
//      Song(
//        id: 2,
//        band: 'Van Halen',
//        title: 'Eruption',
//        duration: '01:42',
//        albumImg: 'images/vanhalen.jpg',
//        fileUri: 'music/musica2.mp3',
//        album: 'Van Halen',
//      ),
//      Song(
//        id: 3,
//        band: 'Led Zeppelin',
//        title: 'Black Dog',
//        duration: '04:54',
//        albumImg: 'images/vanhalen.jpg',
//        fileUri: 'music/musica3.mp3',
//        album: 'Led Zeppelin IV',
//      ),
//    ];
//
//    final myPlaylist = Playlist(
//      id: 1,
//      name: 'Best of Rock',
//      description: 'As melhores do Rock clássico',
//      imageUrl: 'images/playlistcover.jpg', // Coloque um caminho válido
//      songs: mockSongs,
//    );
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginAndLoadAlbum());
  }
}

/// Widget que faz login e depois carrega a página de álbum
class LoginAndLoadAlbum extends StatefulWidget {
  @override
  State<LoginAndLoadAlbum> createState() => _LoginAndLoadAlbumState();
}

class _LoginAndLoadAlbumState extends State<LoginAndLoadAlbum> {
  late Future<void> _loginFuture;

  @override
  void initState() {
    super.initState();
    // Executa o login quando o widget é criado
    _loginFuture = _performLogin();
  }

  Future<void> _performLogin() async {
    try {
      print('🔐 Iniciando autenticação...');
      final resultToken = await ApiParams.obterToken();
      
      if (resultToken == null) {
        throw Exception('Não foi possível obter o token de acesso.');
      }
      
      print('✅ Autenticação bem-sucedida! Token carregado.');
    } catch (e) {
      print('❌ Erro durante autenticação: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loginFuture,
      builder: (context, snapshot) {
        // Carregando/Autenticando
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.greenAccent),
                    const SizedBox(height: 20),
                    const Text(
                      '🔐 Autenticando...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Erro na autenticação
        if (snapshot.hasError) {
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'Erro ao autenticar',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loginFuture = _performLogin();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Login bem-sucedido - Carrega a página de álbum
        return AlbumPage(albumId: 3);
      },
    );
  }
}
