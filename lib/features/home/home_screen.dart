import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/api/character_api.dart';
import 'package:rick_and_morty/core/api/i_api.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IApi _apiClient = CharacterApi();
  late Future<ApiResponse> _charactersFuture;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _charactersFuture = _apiClient.getCharacter(page: _currentPage);
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _charactersFuture = _apiClient.getCharacter(page: _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Персонажи Рик и Морти')),
      body: FutureBuilder<ApiResponse>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final apiResponse = snapshot.data!;
          final characters = apiResponse.results;
          final info = apiResponse.info;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CharacterWidget(character: character);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (info.prev != null)
                      ElevatedButton(
                        onPressed: () => _loadPage(_currentPage - 1),
                        child: const Text('Назад'),
                      )
                    else
                      const SizedBox.shrink(),
                    Text('Стр $_currentPage из ${info.pages}'),
                    if (info.next != null)
                      ElevatedButton(
                        onPressed: () => _loadPage(_currentPage + 1),
                        child: const Text('Следующая'),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key, required this.character});

  final CharacterModel character;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: [Image.network(character.image)]));
  }
}
