import 'package:spotilike_front/class/song.dart';
import 'package:spotilike_front/class/playlist.dart';

/// Enum para controlar o modo de repetição
enum RepeatMode {
  none,      // Sem repetição
  one,       // Repetir uma música
  all,       // Repetir toda a fila
}

/// Classe para gerenciar a fila de reprodução de músicas
class QueueManager {
  late List<Song> _queue;
  int _currentIndex = 0;
  RepeatMode _repeatMode = RepeatMode.none;
  List<int> _shuffleIndices = [];
  bool _isShuffleEnabled = false;
  
  /// Construtor padrão
  QueueManager() {
    _queue = [];
    _currentIndex = 0;
  }
  
  /// Construtor a partir de uma lista de músicas
  QueueManager.fromSongs(List<Song> songs) {
    _queue = List.from(songs);
    _currentIndex = 0;
    _generateShuffleIndices();
  }
  
  /// Construtor a partir de uma playlist
  QueueManager.fromPlaylist(Playlist playlist) {
    _queue = List.from(playlist.songs);
    _currentIndex = 0;
    _generateShuffleIndices();
  }
  
  // ==================== GETTERS ====================
  
  /// Obtém a fila atual
  List<Song> get queue => List.unmodifiable(_queue);
  
  /// Obtém a música atual
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  
  /// Obtém o índice atual
  int get currentIndex => _currentIndex;
  
  /// Obtém o tamanho da fila
  int get queueLength => _queue.length;
  
  /// Obtém o modo de repetição
  RepeatMode get repeatMode => _repeatMode;
  
  /// Verifica se o shuffle está ativado
  bool get isShuffleEnabled => _isShuffleEnabled;
  
  /// Obtém a próxima música sem avançar
  Song? get nextSong {
    int nextIndex = _getNextIndex();
    return nextIndex >= 0 && nextIndex < _queue.length
        ? _queue[nextIndex]
        : null;
  }
  
  /// Obtém a música anterior sem retroceder
  Song? get previousSong {
    int prevIndex = _getPreviousIndex();
    return prevIndex >= 0 && prevIndex < _queue.length
        ? _queue[prevIndex]
        : null;
  }
  
  // ==================== MÉTODOS DE NAVEGAÇÃO ====================
  
  /// Avança para a próxima música
  /// Retorna a próxima música ou null se não houver
  Song? next() {
    if (_queue.isEmpty) return null;
    
    _currentIndex = _getNextIndex();
    return currentSong;
  }
  
  /// Retrocede para a música anterior
  /// Retorna a música anterior ou null se não houver
  Song? previous() {
    if (_queue.isEmpty) return null;
    
    _currentIndex = _getPreviousIndex();
    return currentSong;
  }
  
  /// Pula para uma música específica pelo índice
  Song? jumpToIndex(int index) {
    if (index < 0 || index >= _queue.length) {
      return null;
    }
    _currentIndex = index;
    return currentSong;
  }
  
  /// Pula para uma música específica
  bool jumpToSong(Song song) {
    int index = _queue.indexOf(song);
    if (index != -1) {
      _currentIndex = index;
      return true;
    }
    return false;
  }
  
  // ==================== MÉTODOS DE GERENCIAMENTO DA FILA ====================
  
  /// Adiciona uma música ao final da fila
  void addSong(Song song) {
    _queue.add(song);
    _generateShuffleIndices();
  }
  
  /// Adiciona múltiplas músicas ao final da fila
  void addSongs(List<Song> songs) {
    _queue.addAll(songs);
    _generateShuffleIndices();
  }
  
  /// Adiciona uma música na posição específica
  void insertSongAt(int index, Song song) {
    if (index < 0 || index > _queue.length) return;
    
    _queue.insert(index, song);
    if (index <= _currentIndex) {
      _currentIndex++;
    }
    _generateShuffleIndices();
  }
  
  /// Remove uma música da fila
  bool removeSong(Song song) {
    int index = _queue.indexOf(song);
    if (index == -1) return false;
    
    return _removeSongAt(index);
  }
  
  /// Remove uma música pela posição
  bool removeSongAt(int index) {
    if (index < 0 || index >= _queue.length) return false;
    return _removeSongAt(index);
  }
  
  /// Remove a música atual
  bool removeCurrentSong() {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _removeSongAt(_currentIndex);
    }
    return false;
  }
  
  /// Limpa toda a fila
  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _shuffleIndices.clear();
  }
  
  /// Define uma nova fila
  void setQueue(List<Song> songs) {
    _queue = List.from(songs);
    _currentIndex = 0;
    _generateShuffleIndices();
  }
  
  /// Define a fila a partir de uma playlist
  void setQueueFromPlaylist(Playlist playlist) {
    setQueue(playlist.songs);
  }
  
  /// Move uma música para uma nova posição
  bool moveSong(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _queue.length ||
        toIndex < 0 || toIndex >= _queue.length) {
      return false;
    }
    
    Song song = _queue.removeAt(fromIndex);
    _queue.insert(toIndex, song);
    
    // Ajusta o índice atual se necessário
    if (fromIndex == _currentIndex) {
      _currentIndex = toIndex;
    } else if (fromIndex < _currentIndex && toIndex >= _currentIndex) {
      _currentIndex--;
    } else if (fromIndex > _currentIndex && toIndex <= _currentIndex) {
      _currentIndex++;
    }
    
    _generateShuffleIndices();
    return true;
  }
  
  // ==================== MÉTODOS DE REPETIÇÃO E SHUFFLE ====================
  
  /// Alterna o modo de repetição
  RepeatMode toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    return _repeatMode;
  }
  
  /// Define o modo de repetição
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
  }
  
  /// Ativa/desativa o shuffle
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
  }
  
  /// Define se o shuffle está ativado
  void setShuffle(bool enabled) {
    _isShuffleEnabled = enabled;
  }
  
  /// Embaralha a fila mantendo a música atual
  void shuffleQueue() {
    if (_queue.isEmpty) return;
    
    Song currentSong = _queue[_currentIndex];
    
    // Remove a música atual
    _queue.removeAt(_currentIndex);
    
    // Embaralha o resto
    _queue.shuffle();
    
    // Adiciona a música atual no início
    _queue.insert(0, currentSong);
    _currentIndex = 0;
    
    _generateShuffleIndices();
  }
  
  // ==================== MÉTODOS AUXILIARES PRIVADOS ====================
  
  /// Obtém o próximo índice com base nas configurações de repetição e shuffle
  int _getNextIndex() {
    if (_queue.isEmpty) return -1;
    
    if (_isShuffleEnabled) {
      int nextPos = _shuffleIndices.indexOf(_currentIndex) + 1;
      if (nextPos >= _shuffleIndices.length) {
        if (_repeatMode == RepeatMode.none || _repeatMode == RepeatMode.one) {
          return -1;
        }
        return _shuffleIndices[0];
      }
      return _shuffleIndices[nextPos];
    }
    
    // Sem shuffle
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.none || _repeatMode == RepeatMode.one) {
        return -1;
      }
      return 0;
    }
    return nextIndex;
  }
  
  /// Obtém o índice anterior com base nas configurações
  int _getPreviousIndex() {
    if (_queue.isEmpty) return -1;
    
    if (_isShuffleEnabled) {
      int prevPos = _shuffleIndices.indexOf(_currentIndex) - 1;
      if (prevPos < 0) {
        return -1;
      }
      return _shuffleIndices[prevPos];
    }
    
    // Sem shuffle
    return _currentIndex - 1;
  }
  
  /// Remove uma música pelo índice interno
  bool _removeSongAt(int index) {
    _queue.removeAt(index);
    
    // Ajusta o índice atual
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      if (_currentIndex >= _queue.length && _queue.isNotEmpty) {
        _currentIndex = _queue.length - 1;
      }
    }
    
    _generateShuffleIndices();
    return true;
  }
  
  /// Gera os índices para o shuffle
  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_queue.length, (i) => i);
    if (_isShuffleEnabled) {
      _shuffleIndices.shuffle();
    }
  }
  
  // ==================== MÉTODOS DE INFORMAÇÃO ====================
  
  /// Obtém a posição de uma música na fila
  int getSongIndex(Song song) {
    return _queue.indexOf(song);
  }
  
  /// Verifica se uma música está na fila
  bool containsSong(Song song) {
    return _queue.contains(song);
  }
  
  /// Obtém as músicas restantes (a partir da próxima)
  List<Song> getRemainingQueue() {
    if (_currentIndex + 1 >= _queue.length) {
      return [];
    }
    return _queue.sublist(_currentIndex + 1);
  }
  
  /// Obtém as músicas já tocadas (até a atual)
  List<Song> getPlayedQueue() {
    if (_currentIndex < 0) {
      return [];
    }
    return _queue.sublist(0, _currentIndex + 1);
  }
  
  /// Obtém um resumo da fila
  String getQueueSummary() {
    return 'Fila: ${_queue.length} músicas | '
           'Atual: $_currentIndex | '
           'Shuffle: $_isShuffleEnabled | '
           'Repetição: $_repeatMode';
  }
}
