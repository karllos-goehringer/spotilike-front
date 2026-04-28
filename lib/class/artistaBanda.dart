class ArtistaBanda {
  final int id;
  final String name;
  final String imageUrl;
  final String? description;
  ArtistaBanda({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory ArtistaBanda.fromJson(Map<String, dynamic> json) {
    return ArtistaBanda(
      id: json['PK_artistID'] ?? 0,
      name: json['artistName']?.toString() ?? 'Artista desconhecido',
      imageUrl: json['artistimage']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}