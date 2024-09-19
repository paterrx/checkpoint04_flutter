import 'dart:convert';
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:http/http.dart' as http;

const baseUrl = 'https://api.themoviedb.org/3/';
const key = '?api_key=$apiKey';
const backendUrl = 'http://localhost:3000/movies';  // URL do backend local

class ApiServices {
  // Fetch Top Rated Movies
  Future<Result> getTopRatedMovies() async {
    var endPoint = 'movie/top_rated';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar filmes top-rated');
  }

  // Fetch Now Playing Movies
  Future<Result> getNowPlayingMovies() async {
    var endPoint = 'movie/now_playing';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar filmes em cartaz');
  }

  // Fetch Upcoming Movies
  Future<Result> getUpcomingMovies() async {
    var endPoint = 'movie/upcoming';
    final url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar filmes próximos');
  }

  // Fetch Popular Movies
  Future<Result> getPopularMovies() async {
    const endPoint = 'movie/popular';
    const url = '$baseUrl$endPoint$key';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar filmes populares');
  }

  // Search Movies by text
  Future<Result> getSearchedMovie(String searchText) async {
    final endPoint = 'search/movie?query=$searchText';
    final url = '$baseUrl$endPoint$key';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3NTAyYjhjMDMxYzc5NzkwZmU1YzBiNGY5NGZkNzcwZCIsInN1YiI6IjYzMmMxYjAyYmE0ODAyMDA4MTcyNjM5NSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.N1SoB26LWgsA33c-5X0DT5haVOD4CfWfRhwpDu9eGkc'
    });
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar a busca de filmes');
  }

  // Marcar filme como "assistido" e salvar se o usuário gostou ou não
  Future<void> markAsWatched(String movieId, bool liked) async {
    final url = '$backendUrl/$movieId/watched';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode({'watched': true, 'liked': liked}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Filme marcado como assistido e gostou: $liked');
    } else {
      throw Exception('Erro ao marcar como assistido');
    }
  }

  // Marcar filme como "não assistido"
  Future<void> markAsNotWatched(String movieId) async {
    final url = '$backendUrl/$movieId/not-watched';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode({'watched': false}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Filme marcado como não assistido');
    } else {
      throw Exception('Erro ao marcar como não assistido');
    }
  }

  // Avaliar filme e salvar a avaliação
  Future<void> rateMovie(String movieId, int rating) async {
    final url = '$backendUrl/$movieId/rating';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode({'rating': rating}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Filme avaliado com sucesso: $rating');
    } else {
      throw Exception('Erro ao avaliar o filme');
    }
  }

  Future<Movie?> getMovieById(String movieId) async {
    final url = '$baseUrl/$movieId?api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Se a resposta for OK, parsear o JSON para o modelo Movie
        final Map<String, dynamic> movieData = json.decode(response.body);
        return Movie.fromJson(movieData); // Certifique-se de ter o método fromJson no modelo Movie
      } else {
        print('Erro ao buscar o filme: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }
}
