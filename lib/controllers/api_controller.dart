import 'dart:async';
import 'dart:convert';
import '../models/movie_model.dart';
import 'package:http/http.dart' as http;
import './database_controller.dart';

class ApiController {
  static ApiController _apiController;
  static String _apiHost = 'https://api.themoviedb.org/3/discover/movie';
  static String _apiKey = 'Place_your_apikey_here';
  static String _language = 'en-US';
  static String _sortBy = "release_date.desc";
  static DateTime _now = DateTime.now();
  static DateTime _date = DateTime(_now.year, _now.month, _now.day);
  static String _year = _date.toString();
  static String _imagePath = 'https://image.tmdb.org/t/p/w300/';
  static String _additional = 'include_adult=false&include_video=false';
  DatabaseController _databaseController = DatabaseController();
  String _base =
      '$_apiHost?api_key=$_apiKey&language=$_language&sort_by=$_sortBy&$_additional&primary_release_date.lte=$_year';
  ApiController._createInstance();
  List<Movie> _movieList = [];
  int _counter = 0;
  final _genreMap = const {
    28: "Action",
    12: "Adventure",
    16: "Animation",
    35: "Comedy",
    80: "Crime",
    99: "Documentary",
    18: "Drama",
    10751: "Family",
    14: "Fantasy",
    36: "History",
    27: "Horror",
    10402: "Music",
    9648: "Mystery",
    10749: "Romance",
    878: "Science-Fiction",
    10770: "TV-Movie",
    53: "Thriller",
    10752: "War",
    37: "Western"
  };
  // Making sure we have only one instance of the api controller.
  factory ApiController() {
    if (_apiController == null) {
      _apiController = ApiController._createInstance();
    }
    return _apiController;
  }

  // private function used by fetchData() to retrieve the latest movies.
  Future<List<Movie>> _getPage(int page) async {
    String url = _base + '&page=$page';
    List<Movie> movieList = [];
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
    var body = json.decode(response.body);
    var results = body['results'];
    for (final result in results) {
      result['genre'] = '';
      for (final genre in result['genre_ids']) {
        result['genre'] = result['genre'] + ' ' + _genreMap[genre];
      }
      if (result['poster_path'] != null) {
        result['poster_path'] = _imagePath + result['poster_path'];
      }
      result['is_favorite'] = await _databaseController.contain(result['id']);
      movieList.add(Movie.fromMapObject(result));
    }
    return movieList;
  }

  //this function is used by the latest movies screen everytime it loads or refresh
  Future<List<Movie>> fetchData() async {
    _counter = _counter + 1;
    List<Movie> newMovieList = await _getPage(_counter);
    _movieList = List.from(_movieList)..addAll(newMovieList);
    return _movieList;
  }

  // this is used to reset the counter and the data.
  void reset() {
    _counter = 0;
    _movieList = [];
  }

  int count() {
    return _movieList.length;
  }

  List<Movie> get movieList => _movieList;

  //this method will retrive the movie's details giving a movie id
  Future<Map<String, dynamic>> getDetail(int id) async {
    String url =
        'https://api.themoviedb.org/3/movie/$id?api_key=$_apiKey&language=en-US';
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
    var body = json.decode(response.body);
    return body;
  }

  //this method will return the a maximum of 20 movies similar to the one displayed.
  Future<List<Movie>> getSimilarMovies(int id) async {
    String url =
        'https://api.themoviedb.org/3/movie/$id/similar?api_key=$_apiKey&language=en-US&page=1';
    List<Movie> movieList = [];
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
    var body = json.decode(response.body);
    var results = body['results'];
    for (final result in results) {
      result['genre'] = '';
      for (final genre in result['genre_ids']) {
        result['genre'] = result['genre'] + ' ' + _genreMap[genre];
      }
      if (result['poster_path'] != null) {
        result['poster_path'] = _imagePath + result['poster_path'];
      }
      result['is_favorite'] = await _databaseController.contain(result['id']);
      movieList.add(Movie.fromMapObject(result));
    }
    return movieList;
  }

  // this api calls will take a query and return a list of matching movies
  Future<List<Movie>> search(String text, int page) async {
    String url =
        'https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&language=en-US&query=$text&page=$page&include_adult=false';
    List<Movie> movieList = [];
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
    var body = json.decode(response.body);
    var results = body['results'];
    for (final result in results) {
      result['genre'] = '';
      for (final genre in result['genre_ids']) {
        result['genre'] = result['genre'] + ' ' + _genreMap[genre];
      }
      if (result['poster_path'] != null) {
        result['poster_path'] = _imagePath + result['poster_path'];
      }
      result['is_favorite'] = await _databaseController.contain(result['id']);
      movieList.add(Movie.fromMapObject(result));
    }
    return movieList;
  }

  // this will return the casts of a given movie id
  Future<List<dynamic>> getCasts(int movieId) async {
    String url =
        'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$_apiKey';
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
    var body = json.decode(response.body);
    var results = body['cast'];
    return results;
  }
}
