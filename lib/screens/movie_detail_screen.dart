import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../controllers/database_controller.dart';
import '../controllers/api_controller.dart';
import 'package:share/share.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie _movie;
  MovieDetailScreen(this._movie);
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState(this._movie);
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie _movie;
  Map<String, dynamic> _detail = Map();
  List<Movie> movieList = [];
  ApiController apiController = ApiController();
  DatabaseController databaseController = DatabaseController();
  List<dynamic> casts = [];
  _MovieDetailScreenState(this._movie);

  Future<void> getData() async {
    _detail = await apiController.getDetail(_movie.id);
    movieList = await apiController.getSimilarMovies(_movie.id);
    casts = await apiController.getCasts(_movie.id);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_movie.title),
      ),
      body: body(),
    );
  }

  ListView body() {
    return ListView(
      children: <Widget>[
        FittedBox(
          child: _movie.posterPath != null
              ? Image.network(_movie.posterPath)
              : Icon(Icons.broken_image),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: GestureDetector(
                  child: Icon(Icons.share),
                  onTap: () {
                    Share.share(
                        'Checkout this awesome movie. https://www.imdb.com/title/${_detail['imdb_id']}');
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: GestureDetector(
                  child: _movie.isFavorite
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite, color: Colors.grey),
                  onTap: () {
                    if (_movie.isFavorite) {
                      databaseController.deleteMovie(_movie.id);
                      _movie.favorite = false;
                      if (mounted) {
                        setState(() {});
                      }
                    } else {
                      databaseController.insertMovie(_movie);
                      _movie.favorite = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        ListTile(
          title: _detail['overview'] == null || _detail['overview'] == ''
              ? Text(
                  "N/A",
                  style: TextStyle(fontSize: 24.0),
                )
              : Text(
                  _detail['overview'],
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.justify,
                ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            'Similar Movies',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
        SizedBox(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movieList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () {
                    getDetail(movieList[index]);
                  },
                  child: movieList[index].posterPath != null
                      ? Image.network(movieList[index].posterPath)
                      : Icon(Icons.broken_image),
                ),
              );
            },
          ),
          height: 100.0,
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            'Casts Details',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
        SizedBox(
          height: 500.0,
          child: ListView.builder(
            itemCount: casts.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: casts[index]['profile_path'] == null
                    ? Icon(Icons.broken_image)
                    : Image.network(
                        'https://image.tmdb.org/t/p/w300/' +
                            casts[index]['profile_path'],
                        width: 50.0,
                        height: 50.0),
                title: Text(casts[index]['name']),
                subtitle: Text(casts[index]['character']),
              );
            },
          ),
        )
      ],
    );
  }

  Future<void> getDetail(Movie movie) async {
    bool fav = await databaseController.contain(movie.id);
    Movie exploreMovie;
    if (movie.posterPath == null) {
      exploreMovie = Movie(movie.id, movie.title, movie.genre, fav);
    } else {
      exploreMovie =
          Movie(movie.id, movie.title, movie.genre, fav, movie.posterPath);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailScreen(exploreMovie),
        ));
  }
}
