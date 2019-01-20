class Movie {
  int _id;
  String _title;
  String _genre;
  String _posterPath;
  bool _isFavorite;

  Movie(this._id, this._title, this._genre, this._isFavorite,
      [this._posterPath]);

  int get id => _id;
  String get title => _title;
  String get genre => _genre;
  String get posterPath => _posterPath;
  bool get isFavorite => _isFavorite;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = _id;
    map['title'] = _title;
    map['genre'] = _genre;
    map['poster_path'] = _posterPath;
    return map;
  }

  Movie.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._genre = map['genre'];
    this._posterPath = map['poster_path'];
    this._isFavorite = map['is_favorite'];
  }

  set favorite(bool choice) {
    this._isFavorite = choice;
  }
}
