import 'package:flutter/material.dart';
import 'pages/music_player.dart';
//import 'pages/album.dart';
import '../class/album.dart';
import '../class/song.dart';
import 'pages/playlist.dart';

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
    return MaterialApp(home: MusicPlayerPage());
  }
}
