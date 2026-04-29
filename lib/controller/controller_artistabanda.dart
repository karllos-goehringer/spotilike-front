import 'dart:convert';
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/artista_banda.dart';
import 'package:http/http.dart' as http;
import 'package:spotilike_front/controller/controller_album.dart';
import 'dart:developer' as dev; 
class ControlleArtistabanda {

  static Future<List<ArtistaBanda>> getAllBands() async {
    try{
    final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('${ApiParams.apiBaseUrl}/api/bands/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> bandsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['bands'] ?? [];

        final bands = await Future.wait(bandsJson.map((bandJson) async {
          final baseInfo = ArtistaBanda.fromJson(bandJson);
          final albums = await ControllerAlbum.getAlbumsByBandId(baseInfo.id, baseInfo.typeBand, baseInfo.name);
          return ArtistaBanda(
            id: baseInfo.id,
            name: baseInfo.name,
            typeBand: baseInfo.typeBand,
            imageUrl: baseInfo.imageUrl,
            description: baseInfo.description,
            backgroundImage: baseInfo.backgroundImage,
            albums: albums,
          );
        }));

        dev.log('✅ ${bands.length} bandas carregadas');
        return bands;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return [];
      } else {
        dev.log('❌ Erro ao carregar bandas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return [];
    }
  }
  static Future<List<ArtistaBanda>> getAllArtists() async {
    try{
    final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('${ApiParams.apiBaseUrl}/api/artists/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> bandsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['artists'] ?? jsonResponse['bands'] ?? [];

        final bands = await Future.wait(bandsJson.map((bandJson) async {
          final baseInfo = ArtistaBanda.fromJson(bandJson);
          final albums = await ControllerAlbum.getAlbumsByBandId(baseInfo.id, baseInfo.typeBand, baseInfo.name);
          return ArtistaBanda(
            id: baseInfo.id,
            name: baseInfo.name,
            typeBand: baseInfo.typeBand,
            imageUrl: baseInfo.imageUrl,
            description: baseInfo.description,
            backgroundImage: baseInfo.backgroundImage,
            albums: albums,
          );
        }));

        dev.log('✅ ${bands.length} artistas carregados');
        return bands;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return [];
      } else {
        dev.log('❌ Erro ao carregar bandas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return [];
    }
  }
  static Future<ArtistaBanda?> getBandById(int id, String typeBand) async {
    try{
    final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('${ApiParams.apiBaseUrl}/api/bands/$id/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> bandsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['bands'] ?? [];

        if (bandsJson.isEmpty) return null;

        final artista = ArtistaBanda.fromJson(bandsJson[0]);
        final albums = await ControllerAlbum.getAlbumsByBandId(id, typeBand, artista.name);
        
        dev.log('✅ Banda ${artista.name} carregada');
        return ArtistaBanda(
          id: artista.id,
          name: artista.name,
          typeBand: artista.typeBand,
          imageUrl: artista.imageUrl,
          description: artista.description,
          backgroundImage: artista.backgroundImage,
          albums: albums,
        );
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao carregar bandas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }
  static Future<ArtistaBanda?> getArtistById(int id, String typeBand) async {
    try{
    final headers = await ApiParams.obterHeaders();
      final response = await http.get(
        Uri.parse('${ApiParams.apiBaseUrl}/api/artists/$id/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> bandsJson = jsonResponse is List
            ? jsonResponse
            : jsonResponse['artists'] ?? jsonResponse['bands'] ?? [];
        
        if (bandsJson.isEmpty) return null;

        final artista = ArtistaBanda.fromJson(bandsJson[0]);
        dev.log('✅ Artista ${artista.name} carregado');
        return artista;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else {
        dev.log('❌ Erro ao carregar bandas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }
}
