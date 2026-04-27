import 'package:http/http.dart' as http;
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/song.dart';
import 'dart:typed_data';

class MusicController {
  static const String mediaBaseUrl = '${ApiParams.apiBaseUrl}';

  static Future<Uint8List?> getMusicFile(String fileUri) async {
    print(fileUri);
    try {
      final headers = await ApiParams.obterHeaders();
      final url = '$mediaBaseUrl$fileUri';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('✅ Arquivo de música obtido com sucesso!');
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        print('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else if (response.statusCode == 404) {
        print('❌ Erro 404: Arquivo não encontrado');
        return null;
      } else {
        print('❌ Erro ao baixar arquivo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  static Future<Uint8List?> getMusicFromSong(Song song) async {
    return await getMusicFile(song.fileUri);
  }
  /// Inclui o token na URL para autenticação
  static Future<String?> getMusicStreamUrl(String fileUri) async {
    try {
       final headers = await ApiParams.obterHeaders();
      final url = '$mediaBaseUrl$fileUri';
      print(url);
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return url;
    } catch (e) {
      print('❌ Erro ao gerar URL de stream: $e');
      return null;
    }
  }

  ///Obter URL de stream de um objeto Song
  static Future<String?> getMusicStreamUrlFromSong(Song song) async {
    return await getMusicStreamUrl(song.fileUri);
  }

  ///Verificar disponibilidade do arquivo
  static Future<bool> checkMusicAvailability(String fileUri) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final url = '$mediaBaseUrl$fileUri';

      final response = await http.head(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('✅ Arquivo disponível: $fileUri');
        return true;
      } else if (response.statusCode == 404) {
        print('❌ Arquivo não encontrado: $fileUri');
        return false;
      } else {
        print('⚠️ Status desconhecido: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao verificar disponibilidade: $e');
      return false;
    }
  }
}