import "dart:convert";
import 'package:http/http.dart' as http;
import 'album.dart';
import 'playlist.dart';
import 'song.dart';
import 'localStorage.dart';

var storage = localStorage();

class Requests {
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String allAlbumsEndpoint = '$apiBaseUrl/albums/all';
  static const String allPlaylistsEndpoint = '$apiBaseUrl/playlists/all';
  static const String allAlbumSongsEndpoint = '$apiBaseUrl/songs/all';
  static const String audioArchiveEndpoint = '$apiBaseUrl/audios';
  static const String getImageAlbumEndpoint = '$apiBaseUrl/album/image';
  static const String getImagePlaylistEndpoint = '$apiBaseUrl/playlist/image';
  static const String getImageArtistEndpoint = '$apiBaseUrl/artist/image';
  static const String songEndpoint = '$apiBaseUrl/songs';
  static const String playlistEndpoint = '$apiBaseUrl/playlists';
  static const String albumEndpoint = '$apiBaseUrl/albums';
  static const String artistEndpoint = '$apiBaseUrl/artists';
  static const String bandEndpoint = '$apiBaseUrl/bands';

  audioArchiveRequest(songURL){
    // buscar audio no backend usando o songURL e retornar o arquivo de áudio
  }
  allPlaylistRequest() async {
    try{
      final response = await http.get(Uri.parse(allPlaylistsEndpoint));
      if(response.statusCode == 200){
        final List<dynamic> playlistJson = jsonDecode(response.body);
        storage.addPlaylist(Playlist.fromJson(playlistJson[0]));
      } else {
        throw Exception('Failed to load playlists');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load playlists');
    }
  }
  allAlbumRequest() async {
    try{
      final response = await http.get(Uri.parse(allAlbumsEndpoint));
      if(response.statusCode == 200){
        final List<dynamic> albumJson = jsonDecode(response.body);
        storage.addAlbum(Album.fromJson(albumJson[0]));
      } else {
        throw Exception('Failed to load albums');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load albums');
    } 
}
 allSongRequest() async {
    try{
      final response = await http.get(Uri.parse(allAlbumSongsEndpoint));
      if(response.statusCode == 200){
        final List<dynamic> songJson = jsonDecode(response.body);
        storage.addSong(Song.fromJson(songJson[0]));
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load songs');
    } 
  }
  
 
}