import 'song.dart';
 class Album {
  final int albumid;
  final String title;
  final String artist;
  final String artUri;
  final List<Song> songs;
  Album({
    required this.albumid,
    required this.title,
    required this.artist,
    required this.artUri,
    required this.songs,
  });
  factory Album.fromJson(Map<String, dynamic> json) {
    final String albumOwner = json['owner']?.toString() ?? 'Artista desconhecido';
    
    return Album(
      albumid: json['PK_albumID'] ?? 0,
      title: json['albumName']?.toString() ?? 'Sem título',
      artist: albumOwner,
      artUri: json['albumimage']?.toString() ?? '',
      songs: (json['songs'] as List? ?? [])
          .map((songJson) {
            final map = songJson as Map<String, dynamic>;
            map['owner'] = map['owner'] ?? albumOwner;
            return Song.fromJson(map);
          })
          .toList(),
    );
  }
}