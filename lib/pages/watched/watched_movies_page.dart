import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_app/pages/details/movie_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/models/movie_model.dart';

class WatchedMoviesPage extends StatefulWidget {
  const WatchedMoviesPage({Key? key}) : super(key: key);
  
  @override
  _WatchedMoviesPageState createState() => _WatchedMoviesPageState();
}

class _WatchedMoviesPageState extends State<WatchedMoviesPage> {
  List<Movie> _watchedMovies = [];

  @override
  void initState() {
    super.initState();
    _loadWatchedMovies(); // Carrega os filmes assistidos ao abrir a tela
  }

  Future<void> _loadWatchedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<Movie> watchedMovies = [];

    for (var key in keys) {
      if (key.startsWith('movie_')) {  // Verifica as chaves dos filmes
        final movieJson = prefs.getString(key);
        if (movieJson != null) {
          final movieData = jsonDecode(movieJson);
          final movie = Movie.fromJson(movieData);
          watchedMovies.add(movie);  // Adiciona o filme à lista
        }
      }
    }

    setState(() {
      _watchedMovies = watchedMovies;  // Atualiza o estado com os filmes assistidos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes Assistidos'),
      ),
      body: _watchedMovies.isEmpty
          ? const Center(child: Text('Nenhum filme assistido ainda.'))
          : ListView.builder(
              itemCount: _watchedMovies.length,
              itemBuilder: (context, index) {
                final movie = _watchedMovies[index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie.title),
                  subtitle: Text('Avaliação: ${movie.voteAverage}/10'),
                  onTap: () {
                    // Navega para a página de detalhes do filme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsPage(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
