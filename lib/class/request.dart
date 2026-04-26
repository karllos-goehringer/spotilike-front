import "dart:convert";
import 'package:http/http.dart' as http;
import 'album.dart';
import 'playlist.dart';
import 'song.dart';
import 'localStorage.dart';
import 'api_params.dart';

var storage = LocalStorage();

class Requests {
  static const String apiBaseUrl = ApiParams.apiBaseUrl;
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

  /// Faz requisição GET com autenticação
  static Future<http.Response> _get(String url) async {
    final headers = await ApiParams.obterHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  /// Faz requisição POST com autenticação
  static Future<http.Response> _post(String url, {Map<String, dynamic>? body}) async {
    final headers = await ApiParams.obterHeaders();
    return await http.post(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  /// Faz requisição PUT com autenticação
  static Future<http.Response> _put(String url, {Map<String, dynamic>? body}) async {
    final headers = await ApiParams.obterHeaders();
    return await http.put(Uri.parse(url), headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  /// Faz requisição DELETE com autenticação
  static Future<http.Response> _delete(String url) async {
    final headers = await ApiParams.obterHeaders();
    return await http.delete(Uri.parse(url), headers: headers);
  }

  allPlaylistRequest() async {
    try{
      final response = await _get(allPlaylistsEndpoint);
      if(response.statusCode == 200){
        final List<dynamic> playlistJson = jsonDecode(response.body);
        storage.addPlaylist(Playlist.fromJson(playlistJson[0]));
      } else {
        throw Exception('Failed to load playlists: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load playlists');
    }
  }

  allAlbumRequest() async {
    try{
      final response = await _get(allAlbumsEndpoint);
      if(response.statusCode == 200){
        final List<dynamic> albumJson = jsonDecode(response.body);
        storage.addAlbum(Album.fromJson(albumJson[0]));
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load albums');
    } 
  }

  allSongRequest() async {
    try{
      final response = await _get(allAlbumSongsEndpoint);
      if(response.statusCode == 200){
        final List<dynamic> songJson = jsonDecode(response.body);
        storage.addSong(Song.fromJson(songJson[0]));
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load songs');
    } 
  }
}