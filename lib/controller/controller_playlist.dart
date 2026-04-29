import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/playlist.dart';
import 'dart:developer' as dev;

class PlaylistController {
  static String? userToken;
  static const String apiBaseUrl = ApiParams.apiBaseUrl;

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
            .map((playlistJson) => Playlist.fromJson(playlistJson, []))
            .toList();

        dev.log('✅ Playlists carregadas: ${playlists.length}');
        return playlists;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao carregar playlists: ${response.statusCode}');
        dev.log('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  static Future<Playlist?> getPlaylist(int playlistID) async {
    
    final headers = await ApiParams.obterHeaders();
    final responseDadosPlaylist = await http.get(
      Uri.parse('$getPlaylistsEndpoint$playlistID/'),
      headers: headers,
    );
    final jsonDadosPlaylist = jsonDecode(responseDadosPlaylist.body);
    dev.log(jsonDadosPlaylist.toString());
    final musicasPlaylist = await http.get(
      Uri.parse('$getPlaylistsEndpoint$playlistID/songs/'),
      headers: headers,
    );
    
    final jsonMusicasPlaylist =  jsonDecode(musicasPlaylist.body);
    //pra cada musica buscar o album e o artista enfiar o artista e o album na musica
    var i = 0;
    for (var musica in jsonMusicasPlaylist) {
    
    final albumid = jsonMusicasPlaylist[i]['album_pk_albumid1'];
    i++;
    final dadosAlbum = await http.get(
      Uri.parse('$apiBaseUrl/api/albums/$albumid/'),
      headers: headers,
    );
    final jsonDadosAlbum = jsonDecode(dadosAlbum.body);
    musica['album'] = jsonDadosAlbum['albumName'];
    musica['albumImg'] = jsonDadosAlbum['albumimage'];
    musica['albumid'] = albumid;
    final dadosArtistas = await http.get(
      Uri.parse('$apiBaseUrl/api/albums/$albumid/get_owner/'),
      headers: headers,
    );
    final jsonDadosArtistas = jsonDecode(dadosArtistas.body);
    musica['owner'] = jsonDadosArtistas['data'][0]['name'];
    
    }
    return Playlist.fromJson(jsonDadosPlaylist,jsonMusicasPlaylist);

  }

  /// Retorna a playlist criada
  static Future<Playlist?> createPlaylist({
    required int userID,
    required String name,
    required String description,
    XFile? image,
  }) async {
    try {
      final headers = await ApiParams.obterHeaders();
      // Removemos o Content-Type manual para que o MultipartRequest defina o boundary correto
      headers.remove('Content-Type');

      var request = http.MultipartRequest('POST', Uri.parse(createPlaylistEndpoint));
      request.headers.addAll(headers);

      request.fields['user_id'] = userID.toString();
      request.fields['plName'] = name;
      request.fields['description'] = description;

      if (image != null) {
        final imageBytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'plImage',
            imageBytes,
            filename: image.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Ajuste conforme a estrutura de resposta da API
        final playlistData = jsonResponse is Map
            ? jsonResponse
            : jsonResponse['playlist'];
        final playlist = Playlist.fromJson(playlistData, []);

        dev.log('✅ Playlist criada com sucesso: ${playlist.name}');
        return playlist;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao criar playlist: ${response.statusCode}');
        dev.log('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição ou processar JSON: $e');
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
        dev.log('✅ Playlist removida com sucesso!');
        return true;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else if (response.statusCode == 404) {
        dev.log('❌ Erro 404: Playlist não encontrada');
        return false;
      } else {
        dev.log('❌ Erro ao remover playlist: ${response.statusCode}');
        dev.log('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }

  //Adicionar música a uma playlist
  static Future<bool> addSongPlaylist(int playlistID, int songID, int playlistLength) async {
    try {
      final headers = await ApiParams.obterHeaders();

      final body = jsonEncode({'playlist_id': playlistID, 'song_id': songID, 'ordem': playlistLength + 1});

      final response = await http.post(
        Uri.parse(addSongEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dev.log('✅ Música adicionada à playlist!');
        return true;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else {
        dev.log('❌ Erro ao adicionar música: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }

  ///Remover música de uma playlist
  static Future<bool> removeSongPlaylist(int playlistID, int songID) async {
    try {
      final headers = await ApiParams.obterHeaders();

      final body = jsonEncode({'playlist_id': playlistID, 'song_id': songID});

      final response = await http.post(
        Uri.parse(removeSongEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        dev.log('✅ Música removida da playlist!');
        return true;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else {
        dev.log('❌ Erro ao remover música: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return false;
    }
  }
 
  static Future<bool> atualizarPlaylist(int playlistID, String name, String description, XFile? image) async {
    try {
      final headers = await ApiParams.obterHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest('PUT', Uri.parse('$getPlaylistsEndpoint$playlistID/'));
      request.headers.addAll(headers);

      request.fields['plName'] = name;
      request.fields['description'] = description;

      if (image != null) {
        final imageBytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'plImage',
            imageBytes,
            filename: image.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        dev.log('✅ Playlist atualizada com sucesso!');
        return true;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return false;
      } else {
        dev.log('❌ Erro ao atualizar playlist: ${response.statusCode}');
        dev.log('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição ou processar JSON: $e');
      return false;
    }
}
}