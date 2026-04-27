import 'song.dart';
class Playlist {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Song> songs;
  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
  });
  factory Playlist.fromJson(Map<String, dynamic> json, List<dynamic> songsJson) {
    return Playlist(
      id: json['PK_playlistID'] ?? 0,
      name: json['plName'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['plImage'] ?? '',
      songs: songsJson.map((songJson) => Song.fromJson(songJson)).toList(),
    );
  }  
}
