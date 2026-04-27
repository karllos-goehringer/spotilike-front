
import 'package:spotilike_front/controller/controller_music.dart';
import 'dart:typed_data';

class Song {
  final String id;
  final String band;
  final String title;
  final String duration;
  final String albumImg;
  final String fileUri;
  final String album;
  final String generoMusical;
  
  Song({
    required this.id,
    required this.band,
    required this.title,
    required this.duration,
    required this.albumImg,
    required this.fileUri,
    required this.album,
    this.generoMusical = '',
  });
  
 factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['PK_songID']?.toString() ?? '', 
      band: json['owner'] ?? 'Unknown Band',
      title: json['songtitle'] ?? 'Unknown Title',
      duration: json['timeMusic'] ?? '00:00',
      albumImg: (json['albumimage'] ?? json['albumImg'] ?? json['album_art'] ?? '').toString(),
      fileUri: json['songpath'] ?? '',
      album: json['album'] ?? 'Unknown Album',
      generoMusical: json['generoMusical'] ?? '',
    );
  }
  
  /// 🎵 Obter o arquivo de áudio desta música com autenticação
  /// Retorna Uint8List com os bytes do arquivo
  Future<Uint8List?> requestMusicFile() async {
    return await MusicController.getMusicFromSong(this);
  }
  
  /// 🎵 Obter URL de stream para reprodução em tempo real
  Future<String?> getStreamUrl() async {
    return await MusicController.getMusicStreamUrlFromSong(this);
  }
  
  /// 🎵 Verificar se o arquivo está disponível
  Future<bool> checkAvailability() async {
    return await MusicController.checkMusicAvailability(this.fileUri);
  }
}