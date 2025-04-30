class TMDBMetadata {
  final String? tmdbId;
  final String? posterPath;
  final String? overview;
  final double? rating;
  final String? releaseDate;
  final List<String>? genres;

  TMDBMetadata({
    this.tmdbId,
    this.posterPath,
    this.overview,
    this.rating,
    this.releaseDate,
    this.genres,
  });

  Map<String, dynamic> toJson() {
    return {
      'tmdbId': tmdbId,
      'posterPath': posterPath,
      'overview': overview,
      'rating': rating,
      'releaseDate': releaseDate,
      'genres': genres,
    };
  }

  factory TMDBMetadata.fromJson(Map<String, dynamic> json) {
    return TMDBMetadata(
      tmdbId: json['tmdbId'],
      posterPath: json['posterPath'],
      overview: json['overview'],
      rating: json['rating'],
      releaseDate: json['releaseDate'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : null,
    );
  }
}