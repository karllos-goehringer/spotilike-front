import 'album.dart';
import 'playlist.dart';
import 'song.dart';

class localStorage{
    List<Album> albums = [];
    List<Playlist> playlists = [];
    List<Song> songs = [];
    addAlbum(Album album){
      albums.add(album);
    }
    addPlaylist(Playlist playlist){
      playlists.add(playlist);
    }
    addSong(Song song){
      songs.add(song);
    }
}