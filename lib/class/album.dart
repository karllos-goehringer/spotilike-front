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
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      title: json['title'],
      artist: json['artist'],
      artUri: json['artUri'],
      songs: (json['songs'] as List).map((songJson) => Song.fromJson(songJson)).toList(),
    );
  }
}