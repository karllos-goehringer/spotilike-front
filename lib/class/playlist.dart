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
  factory Playlist.fromJson(Map<String, dynamic> json){
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      songs: (json['songs'] as List).map((songJson) => Song.fromJson(songJson)).toList(),
    );
  }  
}
