import 'package:http/http.dart' as http;
import 'package:spotilike_front/class/api_params.dart';
import 'package:spotilike_front/class/song.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:just_audio/just_audio.dart';
import 'queue_manager.dart';

class MusicController {
  static const String mediaBaseUrl = ApiParams.apiBaseUrl;

  // Instâncias globais para persistência
  static final AudioPlayer player = AudioPlayer();
  static QueueManager? queueManager;
  
  // Metadados do contexto atual (Playlist/Álbum)
  static String? currentAlbumTitle;
  static String? currentAlbumArtUri;

  /// Carrega uma música no player global
  static Future<void> loadSong(Song song) async {
    try {
      final streamUrl = await song.getStreamUrl();
      if (streamUrl == null) return;

      // Obtém o tag (ID) da música que está carregada no momento
      final currentTag = player.sequenceState?.currentSource?.tag;

      // Só define a URL se for uma música diferente para não resetar o 00:00
      if (currentTag != song.id) {
        await player.stop(); // Garante limpeza antes da nova fonte
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(streamUrl), tag: song.id),
        );
      }
    } catch (e) {
      dev.log('❌ Erro ao carregar música: $e');
    }
  }

  /// Avança para a próxima música na fila
  static Future<void> playNext() async {
    if (queueManager == null) return;
    final nextSong = queueManager!.next();
    if (nextSong != null) {
      await loadSong(nextSong);
      player.play();
    } else {
      await player.stop();
    }
  }

  /// Volta para a música anterior
  static Future<void> playPrevious() async {
    if (queueManager == null) return;
    final prevSong = queueManager!.previous();
    if (prevSong != null) {
      await loadSong(prevSong);
      player.play();
    } else {
      await player.stop();
    }
  }

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