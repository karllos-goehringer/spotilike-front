import 'song.dart';
class Playlist {
  final int id;
  final String name;
  final String? imageUrl;
  final List<Song> songs;
  Playlist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.songs,
  });
  factory Playlist.fromJson(Map<String, dynamic> json, List<dynamic> songsJson) {
    return Playlist(
      id: json['PK_playlistID'] ?? 0,
      name: json['plName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      songs: songsJson.map((songJson) => Song.fromJson(songJson)).toList(),
    );
  }  
}
