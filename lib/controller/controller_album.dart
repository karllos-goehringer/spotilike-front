import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/album.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;
class ControllerAlbum {
  static const String apiBaseUrl = ApiParams.apiBaseUrl;

  // Endpoints dos álbuns
  static const String getAlbumByIdEndpoint = '$apiBaseUrl/api/albums/';
  static const String getAllAlbumsEndpoint = '$apiBaseUrl/api/albums/';
  static const String getAlbumsByGenreEndpoint = '$apiBaseUrl/api/albums/genre/';
  static const String getAlbumDetailEndpoint = '$apiBaseUrl/api/albums/';
  static const String searchAlbumEndpoint = '$apiBaseUrl/api/albums/search/';

  /// 🔵 GET - Obter todos os álbuns
  static Future<List<Album>?> getAllAlbums() async {
    try {
      final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse(getAllAlbumsEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> albumsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['albums'] ?? [];

        final albums = albumsJson
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();

        dev.log('✅ ${albums.length} álbuns carregados');
        return albums;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao carregar álbuns: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  /// 🟢 GET - Obter álbuns por gênero
  /// [genre]: Gênero musical (ex: 'rock', 'pop', 'jazz')
  static Future<List<Album>?> getAlbumsByGenre(String genre) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('$getAlbumsByGenreEndpoint?genre=$genre'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> albumsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['albums'] ?? [];

        final albums = albumsJson
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();

        dev.log('✅ ${albums.length} álbuns do gênero "$genre" carregados');
        return albums;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else if (response.statusCode == 404) {
        dev.log('⚠️ Nenhum álbum encontrado para o gênero: $genre');
        return [];
      } else {
        dev.log('❌ Erro ao carregar álbuns: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  /// 🟡 GET - Obter imagem/arte do álbum
  /// [albumId]: ID do álbum
  /// Retorna os bytes da imagem
  static Future<Uint8List?> getAlbumArt(String albumImage) async {
    if (albumImage.isEmpty) return null;
    try {
      final allHeaders = await ApiParams.obterHeaders();
      // Para imagens, precisamos apenas da autorização, sem Content-Type: application/json
      final headers = {
        if (allHeaders.containsKey('Authorization'))
          'Authorization': allHeaders['Authorization']!,
      };

      // Limpa a URL para evitar /media//media/ caso a API já retorne o prefixo
      String cleanPath = albumImage.startsWith('/')
          ? albumImage.substring(1)
          : albumImage;
      String url = cleanPath.startsWith('http')
          ? cleanPath
          : cleanPath.startsWith('media/')
              ? '$apiBaseUrl/$cleanPath'
              : '$apiBaseUrl/media/$cleanPath';

      // Garante que espaços e caracteres especiais na URL sejam codificados
      final uri = Uri.parse(url);

      dev.log('📥 Obtendo arte do álbum: $albumImage');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        dev.log('✅ Arte do álbum obtida com sucesso!');
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else if (response.statusCode == 404) {
        dev.log('⚠️ Imagem do álbum não encontrada: $albumImage');
        return null;
      } else {
        dev.log('❌ Erro ao carregar imagem: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  /// 🔍 GET - Buscar álbuns por nome
  /// [searchTerm]: Termo de busca
  static Future<List<Album>?> searchAlbums(String searchTerm) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('$searchAlbumEndpoint?q=$searchTerm'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> albumsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['results'] ?? [];

        final albums = albumsJson
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();

        dev.log('✅ ${albums.length} álbuns encontrados para "$searchTerm"');
        return albums;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro na busca: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  /// 📋 GET - Obter detalhes completos de um álbum
  /// [albumId]: ID do álbum
  static Future<Album?> getAlbumDetail(String albumId) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('$getAlbumDetailEndpoint$albumId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          dev.log('❌ Detalhes do álbum: Resposta vazia');
          return null;
        }

        final jsonResponse = jsonDecode(response.body);
        // Se a resposta não for um mapa, algo está errado na API
        if (jsonResponse is! Map<String, dynamic>) return null;

        final album = Album.fromJson(jsonResponse);

        dev.log('✅ Detalhes do álbum carregados: ${album.title}');
        return album;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else if (response.statusCode == 404) {
        dev.log('❌ Álbum não encontrado: $albumId');
        return null;
      } else {
        dev.log('❌ Erro ao carregar álbum: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  static Future<Album?> getAlbumById(String albumId) async {
    try {
      final headers = await ApiParams.obterHeaders();

      final response = await http.get(
        Uri.parse('$getAlbumByIdEndpoint$albumId/'),
        headers: headers,
      );
      final responseOwner = await http.get(
        Uri.parse('$apiBaseUrl/api/albums/$albumId/get_owner/'),
        headers: headers,
      );
      final responseSongs = await http.get(
        Uri.parse('$getAlbumByIdEndpoint$albumId/songs/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        String artistName = 'Artista Desconhecido';
        if (responseOwner.statusCode == 200) {
          try {
            final jsonResponseOwner = jsonDecode(responseOwner.body);
            if (jsonResponseOwner['data'] != null && jsonResponseOwner['data'].isNotEmpty) {
              artistName = jsonResponseOwner['data'][0]['name'];
            }
          } catch (e) {
            dev.log('⚠️ Erro ao processar owner: $e');
          }
        }
        if (responseSongs.statusCode == 200) {
          final jsonSongsResponse = jsonDecode(responseSongs.body);

          jsonResponse['songs'] = jsonSongsResponse;
          jsonResponse['owner'] = artistName;
        } else {
          dev.log(
            '⚠️ Músicas não encontradas ou erro: ${responseSongs.statusCode}',
          );
          jsonResponse['songs'] = []; // Garante que a lista não venha nula
        }

        if (jsonResponse is! Map<String, dynamic>) return null;

        final album = Album.fromJson(jsonResponse);
        dev.log('✅ Detalhes do álbum carregados: ${album.title}');
        return album;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao carregar álbum: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }
  static Future<List<Album>?> getAlbumsByBandId(int bandId, String typeBand, String owner) async {
    try {

      final headers = await ApiParams.obterHeaders();
      var finalResponse;
      if(typeBand == 'artist'){
        final response = await http.get(
        Uri.parse('$apiBaseUrl/api/artists/$bandId/albums/'),
        headers: headers,
        );
        finalResponse = response;
      }else{
        final response = await http.get(
        Uri.parse('$apiBaseUrl/api/bands/$bandId/albums/'),
        headers: headers,
        );
        finalResponse = response;
      }
      if (finalResponse.statusCode == 200) {
        //passar o owner pro album
        final jsonResponse = jsonDecode(finalResponse.body);
        jsonResponse.forEach((album) => album['owner'] = owner);
        final List<Album> albums = (jsonResponse as List)
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();
        dev.log('✅ ${albums.length} álbuns carregados');
        return albums;
      } else {
        dev.log('❌ Erro ao carregar álbuns: ${finalResponse.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }
}
