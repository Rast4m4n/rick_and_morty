import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';
import 'package:rick_and_morty/features/home/home_vm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel(iApi: DiScopeProvider.of(context)!.api);
    vm.loadPage(vm.currentPage);
    vm.loadFavorites(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Персонажи Рик и Морти')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<ApiResponse>(
            future: vm.apiResponse,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              final apiResponse = snapshot.data!;
              final characters = apiResponse.results;
              final info = apiResponse.info;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: characters.length,
                        itemBuilder: (context, index) {
                          final character = characters[index];
                          return CharacterWidget(character: character, vm: vm);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: 12);
                        },
                      ),
                    ),
                    PaginationWidget(info: info, vm: vm),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key, required this.info, required this.vm});

  final InfoModel info;
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (info.prev != null)
            ElevatedButton(
              onPressed: () => vm.loadPage(vm.currentPage - 1),
              child: const Text('Назад'),
            )
          else
            const SizedBox.shrink(),
          Text('Стр ${vm.currentPage} из ${info.pages}'),
          if (info.next != null)
            ElevatedButton(
              onPressed: () => vm.loadPage(vm.currentPage + 1),
              child: const Text('Следующая'),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key, required this.character, required this.vm});
  final HomeViewModel vm;
  final CharacterModel character;
  @override
  Widget build(BuildContext context) {
    final typeCharacter =
        character.type == "" ? 'Без подтипа' : "Тип: ${character.type}";

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.network(character.image),
        title: Text('Имя : ${character.name}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Вид : ${character.species}'), Text(typeCharacter)],
        ),
        trailing: IconButton(
          onPressed: () => vm.doIsFavorite(character, context),
          icon: Icon(
            character.isFavorite ? Icons.star : Icons.star_border_outlined,
          ),
        ),
      ),
    );
  }
}
