import 'package:flutter/material.dart';
import '../controllers/api_controller.dart';
import 'package:loadmore/loadmore.dart';
import '../models/movie_model.dart';
import '../controllers/database_controller.dart';
import './movie_detail_screen.dart';

class SearchMoviesScreen extends StatefulWidget {
  @override
  _SearchMoviesScreenState createState() => _SearchMoviesScreenState();
}

class _SearchMoviesScreenState extends State<SearchMoviesScreen> {
  ApiController apiController = ApiController();
  DatabaseController databaseController = DatabaseController();
  List<Movie> movieList = [];
  int page = 1;
  final textController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ListTile(
          title: TextField(
            controller: textController,
            onSubmitted: (String text) {
              init(textController.text);
            },
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Search...'),
          ),
        ),
      ),
      body: body(),
    );
  }

  Future<bool> _loadMore() async {
    if (textController.text == '') return true;
    List<Movie> newMovieList =
        await apiController.search(textController.text, page);
    movieList = List.from(movieList)..addAll(newMovieList);
    page = page + 1;
    if (mounted) {
      setState(() {});
    }

    return true;
  }

  Future<void> init(String query) async {
    page = 1;
    movieList = [];
    movieList = await apiController.search(query, page);
    page = page + 1;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    page = 1;
    movieList = await apiController.search(textController.text, page);
    page = page + 1;
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
            itemCount: movieList.length,
          ),
          whenEmptyLoad: false,
          delegate: DefaultLoadMoreDelegate(),
          textBuilder: DefaultLoadMoreTextBuilder.english,
        ),
        onRefresh: _refresh,
      ),
    );
  }
}
