import 'package:spotilike_front/class/api_params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:spotilike_front/controller/controller_album.dart';
class ControllerBusca{
  static const String apiBaseURL = ApiParams.apiBaseUrl;

  static Future<Map<String, List<dynamic>>> search(String query) async {
    if (query.isEmpty) {
      return {'albums': [], 'artists': [], 'bands': [], 'playlists': [], 'songs': []};
    }
    final headers = await ApiParams.obterHeaders();
    final response = await http.get(
        Uri.parse('$apiBaseURL/api/search/?q=$query'),
        headers: headers,
        );
    if (response.statusCode != 200){
      return {'albums': [], 'artists': [], 'bands': [], 'playlists': [], 'songs': []};
    }
    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> albums = jsonResponse['albums'] ?? [];
    final List<dynamic> artists = jsonResponse['artists'] ?? [];
    final List<dynamic> bands = jsonResponse['bands'] ?? [];
    final List<dynamic> playlists = jsonResponse['playlists'] ?? [];
    final List<dynamic> songs = jsonResponse['songs'] ?? [];
    for (var album in albums) {
      final albumid = album['PK_albumID'];
      final responseAlbum = await http.get(
        Uri.parse('$apiBaseURL/api/albums/$albumid/get_owner/'),
        headers: headers,
      );
      if (responseAlbum.statusCode == 200) {
        final jsonAlbum = jsonDecode(responseAlbum.body);
        album['owner'] = jsonAlbum['data'][0]['name'];
      } else {
        album['artist_name'] = 'Artista Desconecido';
      }
    }
    for (var song in songs) {
      final songAlbumId = song['album_pk_albumid1'];
      if (songAlbumId == null) continue;

      final album = await ControllerAlbum.getAlbumById(songAlbumId.toString());
      
      if ( album != null) {
        song['album_name'] = album.title;
        song['albumImg'] = album.artUri;
        song['artist'] = album.artist;
      } else {
        song['artist_name'] = 'Artista Desconecido';
        song['album_name'] = 'Album Desconecido';
        song['album_image'] = '';
      }
    }
    return {
      'albums': albums,
      'artists': artists,
      'bands': bands,
      'playlists': playlists,
      'songs': songs,
    };
  }

}