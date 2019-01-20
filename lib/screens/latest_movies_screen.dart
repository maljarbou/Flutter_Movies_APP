import 'package:flutter/material.dart';
import '../controllers/api_controller.dart';
import 'package:loadmore/loadmore.dart';
import '../models/movie_model.dart';
import '../controllers/database_controller.dart';
import './movie_detail_screen.dart';

class LatestMoviesScreen extends StatefulWidget {
  @override
  _LatestMoviesScreenState createState() => _LatestMoviesScreenState();
}

class _LatestMoviesScreenState extends State<LatestMoviesScreen> {
  ApiController apiController = ApiController();
  DatabaseController databaseController = DatabaseController();
  List<Movie> movieList = [];
  @override
  void initState() {
    super.initState();
    movieList = apiController.movieList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Future<bool> _loadMore() async {
    movieList = await apiController.fetchData();
    if (mounted) {
      setState(() {});
    }
    return true;
  }

  Future<void> _refresh() async {
    apiController.reset();
    movieList = await apiController.fetchData();
    if (mounted) {
      setState(() {});
    }
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

  Container body() {
    return Container(
      child: RefreshIndicator(
        child: LoadMore(
          isFinish: apiController.count() >= 10000,
          onLoadMore: _loadMore,
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
              );
            },
            itemCount: apiController.count(),
          ),
          whenEmptyLoad: true,
          delegate: DefaultLoadMoreDelegate(),
          textBuilder: DefaultLoadMoreTextBuilder.english,
        ),
        onRefresh: _refresh,
      ),
    );
  }
}
