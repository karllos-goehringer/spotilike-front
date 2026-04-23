 class Song {
  final int id;
  final String band;
  final String title;
  final String duration;
  final String albumImg;
  final String fileUri;
  final String album;
  Song({
    required this.id,
    required this.band,
    required this.title,
    required this.duration,
    required this.albumImg,
    required this.fileUri,
    required this.album,
  });
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      band: json['band'],
      title: json['title'],
      duration: json['duration'],
      albumImg: json['albumImg'],
      fileUri: json['fileUri'],
      album: json['album'],
    );
  }
}