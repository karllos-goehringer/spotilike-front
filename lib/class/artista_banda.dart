import 'package:spotilike_front/class/album.dart';

class ArtistaBanda {
  final int id;
  final String name;
  final String typeBand;
  final String imageUrl;
  final String? description;
  final List<Album>? albums;
  final String backgroundImage;
  ArtistaBanda({
    required this.id,
    required this.name,
    required this.typeBand,
    required this.imageUrl,
    required this.description,
    this.albums,
    this.backgroundImage = '',
  });

  factory ArtistaBanda.fromJson(Map<String, dynamic> json) {
    final isArtist = json['PK_artistID'] != null;
    final typeBand = isArtist ? 'artist' : 'band';
    
    return  ArtistaBanda(
      id: json['PK_artistID'] ?? json['PK_bandID'] ?? 0,
      name: json['name']?.toString() ?? (isArtist ? 'Artista desconhecido' : 'Banda desconhecida'),
      typeBand: typeBand,
      imageUrl: json['imageArtist']?.toString() ?? json['imageBand']?.toString() ?? '',
      description: json['description']?.toString(),
      albums: null, // Albums should be loaded separately or from a dedicated album list in JSON
      backgroundImage: json['backgroundImage']?.toString() ?? '',
    );
   
  }

  // Adiciona um método copyWith para permitir a criação de uma nova instância com campos atualizados
  ArtistaBanda copyWith({
    int? id,
    String? name,
    String? typeBand,
    String? imageUrl,
    String? description,
    List<Album>? albums,
    String? backgroundImage,
  }) {
    return ArtistaBanda(
      id: id ?? this.id,
      name: name ?? this.name,
      typeBand: typeBand ?? this.typeBand,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      albums: albums ?? this.albums,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}