import 'package:shared_preferences/shared_preferences.dart';
import 'album.dart';
import 'playlist.dart';
import 'song.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  
  List<Album> albums = [];
  List<Playlist> playlists = [];
  List<Song> songs = [];

  /// Salva o token no armazenamento local
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erro ao salvar token: $e');
      return false;
    }
  }

  /// Recupera o token do armazenamento local
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erro ao recuperar token: $e');
      return null;
    }
  }

  /// Remove o token do armazenamento local
  Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print('Erro ao remover token: $e');
      return false;
    }
  }

  addAlbum(Album album) {
    albums.add(album);
  }

  addPlaylist(Playlist playlist) {
    playlists.add(playlist);
  }

  addSong(Song song) {
    songs.add(song);
  }
}