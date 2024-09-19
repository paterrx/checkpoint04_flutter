import 'package:flutter/material.dart';
import 'package:movie_app/pages/home/home_page.dart';
import 'package:movie_app/pages/search/search_page.dart';
import 'package:movie_app/pages/top_rated/top_rated_page.dart';
import 'package:movie_app/pages/watched/watched_movies_page.dart'; // Importe a página dos filmes assistidos

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int paginaAtual = 0;
  PageController pc = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Atualize o comprimento para incluir a nova aba
      child: Scaffold(
        body: PageView(
          controller: pc,
          onPageChanged: (page) {
            setState(() {
              paginaAtual = page;
            });
          },
          children: const [
            HomePage(),
            SearchPage(),
            TopRatedPage(),
            WatchedMoviesPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: paginaAtual,
          iconSize: 30,
          selectedItemColor: Colors.white, // Cor dos ícones e textos selecionados
          unselectedItemColor: Colors.white, // Cor dos ícones e textos não selecionados
          backgroundColor: Colors.black, // Ajuste opcional para o background da barra
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Top Rated'),
            BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Watched'), // Novo botão
          ],
          onTap: (pagina) {
            pc.animateToPage(
              pagina,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
        ),
      ),
    );
  }
}
