import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';
import 'package:rick_and_morty/features/favorite/favorite_vm.dart';
import 'package:rick_and_morty/features/home/home_vm.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteViewModel vm = FavoriteViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранные')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<List<CharacterModel>>(
            future: vm.getFavoriteCharacter(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              final characters = snapshot.data!;

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

class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key, required this.character, required this.vm});
  final FavoriteViewModel vm;
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
