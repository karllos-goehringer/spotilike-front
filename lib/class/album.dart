import 'song.dart';
class Album {
  final String title;
  final String artist;
  final String artUri;
  final List<Song> songs;
  Album({
    required this.title,
    required this.artist,
    required this.artUri,
    required this.songs,
  });
}