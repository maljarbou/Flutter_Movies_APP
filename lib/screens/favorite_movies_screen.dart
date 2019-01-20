import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../controllers/database_controller.dart';
import './movie_detail_screen.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  @override
  _FavoriteMoviesScreenState createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  List<Movie> movieList;
  int count = 0;
  DatabaseController databaseController = DatabaseController();
  @override
  void initState() {
    super.initState();
    setData();
  }

  Future<void> setData() async {
    movieList = await databaseController.getMovieList();
    if (mounted) {
      setState(() {
        count = movieList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return body();
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

  @override
  void dispose() {
    super.dispose();
  }

  Container body() {
    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              onTap: () {
                getDetail(movieList[index]);
              },
              leading: movieList[index].posterPath == null
                  ? Icon(Icons.broken_image)
                  : Image.network(movieList[index].posterPath,
                      width: 50.0, height: 50.0),
              title: Text(movieList[index].title),
              subtitle: Text(
                movieList[index].genre,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: GestureDetector(
                  child: Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    databaseController.deleteMovie(movieList[index].id);
                    movieList[index].favorite = false;
                    if (mounted) {
                      setState(() {
                        setData();
                      });
                    }
                  }));
        },
        itemCount: count,
      ),
    );
  }
}
