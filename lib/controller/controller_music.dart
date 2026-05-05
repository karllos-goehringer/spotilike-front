import 'package:http/http.dart' as http;
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/song.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;
class MusicController {
  static const String mediaBaseUrl = ApiParams.apiBaseUrl;

  /// Método auxiliar para garantir que a URL seja construída corretamente com barras
  static String _buildUrl(String fileUri) {
    if (fileUri.startsWith('http')) return fileUri;

    String cleanPath = fileUri.startsWith('/') ? fileUri.substring(1) : fileUri;
    
    return cleanPath.startsWith('media/')
        ? '$mediaBaseUrl/$cleanPath'
        : '$mediaBaseUrl/media/$cleanPath';
  }

  static Future<Uint8List?> getMusicFile(String fileUri) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final url = _buildUrl(fileUri);
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        dev.log('✅ Arquivo de música obtido com sucesso!');
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        dev.log('❌ Erro 401: Token expirado ou inválido');
        await ApiParams.limparToken();
        return null;
      } else if (response.statusCode == 404) {
        dev.log('❌ Erro 404: Arquivo não encontrado');
        return null;
      } else {
        dev.log('❌ Erro ao baixar arquivo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      dev.log('❌ Erro ao fazer requisição: $e');
      return null;
    }
  }

  static Future<Uint8List?> getMusicFromSong(Song song) async {
    return await getMusicFile(song.fileUri);
  }
  /// Inclui o token na URL para autenticação

  /// Retorna a URL de stream incluindo o token de autenticação como query parameter.
  /// Isso é necessário se o seu backend Django protege os arquivos de mídia.
  static Future<String?> getMusicStreamUrl(String fileUri) async {
    final url = _buildUrl(fileUri);
    final token = await ApiParams.obterToken();

    if (token == null) return url;

    // Verifica se já existe um query parameter para usar ? ou &
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}token=$token';
  }

  ///Obter URL de stream de um objeto Song
  static Future<String?> getMusicStreamUrlFromSong(Song song) async {
    return await getMusicStreamUrl(song.fileUri);
  }

  ///Verificar disponibilidade do arquivo
  static Future<bool> checkMusicAvailability(String fileUri) async {
    try {
      final headers = await ApiParams.obterHeaders();
      final url = _buildUrl(fileUri);

      final response = await http.head(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        dev.log('✅ Arquivo disponível: $fileUri');
        return true;
      } else if (response.statusCode == 404) {
        dev.log('❌ Arquivo não encontrado: $fileUri');
        return false;
      } else {
        dev.log('⚠️ Status desconhecido: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      dev.log('❌ Erro ao verificar disponibilidade: $e');
      return false;
    }
  }
}