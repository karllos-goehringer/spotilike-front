import 'song.dart';
class Playlist {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
  });
}
