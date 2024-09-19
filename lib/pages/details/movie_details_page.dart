import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/services/api_services.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final ApiServices _apiServices = ApiServices();
  int _rating = 0; // Avaliação do filme de 1 a 10
  bool _hasWatched = false; // Status de "Já assisti" ou "Não assisti"
  bool _liked = false; // Gostou do filme ou não

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Carrega as avaliações e o status assistido
      await _loadRating();
      await _loadWatchedStatus();
    } catch (e) {
      print("Erro ao inicializar dados: $e");
    }
  }


  // Alternar status de "já assisti"
  void _toggleWatchedStatus() async {
    setState(() {
      _hasWatched = !_hasWatched;
    });
    // Salvar localmente e enviar para a API
    await _saveWatchedStatus(_hasWatched);
  }

  // Alterar avaliação
  void _setRating(int rating) async {
    setState(() {
      _rating = rating;
    });
    // Salvar localmente e enviar para a API
    await _saveRating(_rating);
  }

  // Marcar se gostou ou não do filme
  void _toggleLiked() async {
    setState(() {
      _liked = !_liked;
    });
    // Salvar localmente e enviar para a API
    await _saveWatchedStatus(_hasWatched); // Também salva se gostou
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do poster do filme
              Center(
                child: Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título do filme
              Text(
                widget.movie.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Data de lançamento do filme
              Text(
                widget.movie.releaseDate == null
                    ? ''
                    : DateFormat("d 'de' MMM 'de' y").format(widget.movie.releaseDate!),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              // Média de votos
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.movie.voteAverage.toStringAsFixed(2)}/10',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sinopse do filme
              Text(
                'Sinopse do filme: \n ${widget.movie.overview}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Avaliação de 1 a 10
              Text(
                'Sua Avaliação: $_rating/10',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildRatingStars(), // Exibe as estrelas para avaliação
              const SizedBox(height: 20),

              // Botão de "Já assisti / Não assisti"
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _toggleWatchedStatus,
                    child: Text(_hasWatched ? "Watched" : "Not Watched"),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _hasWatched
                        ? "Status: Você já assistiu a este filme."
                        : "Status: Você ainda não assistiu.",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o widget de estrelas para avaliação
  Widget _buildRatingStars() {
    return Wrap(
      spacing: 5, // Define o espaçamento horizontal entre as estrelas
      children: List.generate(10, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
          ),
          iconSize: 42, // Ajusta o tamanho do ícone
          onPressed: () {
            _setRating(index + 1);
          },
        );
      }),
    );
  }

  // Salvar avaliação e enviar para a API
  Future<void> _saveRating(int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rating_${widget.movie.id}', rating);
    await _apiServices.rateMovie(widget.movie.id.toString(), rating);
  }

  // Recuperar avaliação
  Future<void> _loadRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rating = prefs.getInt('rating_${widget.movie.id}') ?? 0;
      });
    } catch (e) {
      print('Erro ao carregar avaliação: $e');
    }
  }

  // Salvar status de "Já assisti" e se gostou, e enviar para a API
  Future<void> _saveWatchedStatus(bool hasWatched) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('watched_${widget.movie.id}', hasWatched);  // Salva o status
    if (hasWatched) {
      // Salva os dados relevantes do filme
      await prefs.setString('movie_${widget.movie.id}', jsonEncode(widget.movie.toJson()));
    } else {
      // Remove o filme dos assistidos caso seja desmarcado
      await prefs.remove('movie_${widget.movie.id}');
    }
  }


  // Recuperar status de "Já assisti"
  Future<void> _loadWatchedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _hasWatched = prefs.getBool('watched_${widget.movie.id}') ?? false;
        _liked = prefs.getBool('liked_${widget.movie.id}') ?? false;
      });
    } catch (e) {
      print('Erro ao carregar status de assistido: $e');
    }
  }
}
