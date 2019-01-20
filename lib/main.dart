import 'package:flutter/material.dart';
import './screens/latest_movies_screen.dart' as latestMovies;
import './screens/favorite_movies_screen.dart' as favoriteMovies;
import './screens/search_movies_screen.dart' as searchMovies;

void main() {
  runApp(MaterialApp(
    home: MoviesApp(),
  ));
}

class MoviesApp extends StatefulWidget {
  @override
  _MoviesAppState createState() => _MoviesAppState();
}

class _MoviesAppState extends State<MoviesApp>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3, initialIndex: 1);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest Movies'),
        bottom: TabBar(
          controller: tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: 40.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.home,
                color: Colors.white,
                size: 40.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.star,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          searchMovies.SearchMoviesScreen(),
          latestMovies.LatestMoviesScreen(),
          favoriteMovies.FavoriteMoviesScreen(),
        ],
      ),
    );
  }
}
