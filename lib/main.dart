import 'package:flutter/material.dart';
import 'pages/music_player.dart';
import 'pages/album.dart';

void main() {
  runApp(const MainApp());
}
final albumMock = Album(title: 'Van Halen', artist: 'Van Halen', artUri: 'images/vanhalen.jpg', songs: [
  Song(id: 1, title: 'Runnin\' with the Devil', duration: '3:36', fileUri: 'assets/songs/runnin_with_the_devil.mp3', album: 'Van Halen'),
  Song(id: 2, title: 'Eruption', duration: '1:42', fileUri: 'assets/songs/eruption.mp3', album: 'Van Halen'),
  Song(id: 3, title: 'You Really Got Me', duration: '2:13', fileUri: 'assets/songs/you_really_got_me.mp3', album: 'Van Halen'),
]);
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AlbumPage(album: albumMock));
  }
}
