import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/playlist.dart';
import 'package:spotilike_front/class/localStorage.dart';

class PlaylistController {
  static String? userToken;
  static const String apiBaseUrl = ApiParams.apiBaseUrl;
  static final LocalStorage _storage = LocalStorage();

  // Endpoints das rotas
  static const String createPlaylistEndpoint = '$apiBaseUrl/api/playlists/create_playlist_for_user/';
  static const String getPlaylistsEndpoint = '$apiBaseUrl/api/playlists/';
  static const String deletePlaylistEndpoint = '$apiBaseUrl/api/playlists/';
  static const String addSongEndpoint = '$apiBaseUrl/api/playlists/add_song/';
  static const String removeSongEndpoint = '$apiBaseUrl/api/playlists/remove_song/';

  /// Retorna uma lista de playlists
  static Future<List<Playlist>?> getAllPlaylistUser(int userID) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('$getPlaylistsEndpoint?user_id=$userID'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Ajuste conforme a estrutura da resposta da API
        final List<dynamic> playlistsJson = jsonResponse is List 
            ? jsonResponse 
            : jsonResponse['playlists'] ?? [];
        
        final playlists = playlistsJson
            .map((playlistJson) => Playlist.fromJson(playlistJson))
            .toList();
        
        print('✅ Playlists carregadas: ${playlists.length}');
        return playlists;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        print('❌ Erro ao carregar playlists: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  /// Retorna a playlist criada
  static Future<Playlist?> createPlaylist({
    required int userID,
    required String name,
    required String description,
    String imageUrl = '',
  }) async {
    try {
      final headers = await ApiParams.obterHeaders();
      
      final body = jsonEncode({
        'user_id': userID,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
      });

      final response = await http.post(
        Uri.parse(createPlaylistEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Ajuste conforme a estrutura de resposta da API
        final playlistData = jsonResponse is Map ? jsonResponse : jsonResponse['playlist'];
        final playlist = Playlist.fromJson(playlistData);
        
        print('✅ Playlist criada com sucesso: ${playlist.name}');
        return playlist;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        print('❌ Erro ao criar playlist: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }
  static Future<bool> deletePlaylist(int playlistID) async {
    try {
      final headers = await ApiParams.obterHeaders();
      
      final response = await http.delete(
        Uri.parse('$deletePlaylistEndpoint$playlistID/'),
        headers: headers,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Playlist removida com sucesso!');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else if (response.statusCode == 404) {
        print('❌ Erro 404: Playlist não encontrada');
        return false;
      } else {
        print('❌ Erro ao remover playlist: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }

  //Adicionar música a uma playlist
  static Future<bool> addSongPlaylist(int playlistID, int songID) async {
    try {
      final headers = await ApiParams.obterHeaders();
      
      final body = jsonEncode({
        'playlist_id': playlistID,
        'song_id': songID,
      });

      final response = await http.post(
        Uri.parse(addSongEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Música adicionada à playlist!');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else {
        print('❌ Erro ao adicionar música: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }

  ///Remover música de uma playlist
  static Future<bool> removeSongPlaylist(int playlistID, int songID) async {
    try {
      final headers = await ApiParams.obterHeaders();
      
      final body = jsonEncode({
        'playlist_id': playlistID,
        'song_id': songID,
      });

      final response = await http.post(
        Uri.parse(removeSongEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Música removida da playlist!');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else {
        print('❌ Erro ao remover música: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }
}