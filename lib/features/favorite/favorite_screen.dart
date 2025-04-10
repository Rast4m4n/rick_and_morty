import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/domain/enums/filter_enum.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/features/favorite/favorite_vm.dart';

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
      appBar: AppBar(
        title: const Text('Избранные'),
        actions: [FilterDropDownButton(vm: vm), const SizedBox(width: 8)],
      ),
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
        leading: CachedNetworkImage(
          imageUrl: character.image,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
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

class FilterDropDownButton extends StatelessWidget {
  const FilterDropDownButton({super.key, required this.vm});

  final FavoriteViewModel vm;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.tune),
      itemBuilder: (context) {
        return [
          _buildFilterDropdown<CharacterStatus>(
            title: 'Статус',
            valueEnum: vm.selectedStatus,
            valuesEnum: CharacterStatus.values,
            onChanged: (value) {
              vm.setStatusFilter(value);
              Navigator.pop(context);
            },
            valueEnumAll: CharacterStatus.all,
          ),
          _buildFilterDropdown<CharacterGender>(
            title: 'Пол',
            valueEnum: vm.selectedGender,
            valuesEnum: CharacterGender.values,
            onChanged: (value) {
              vm.setGenderFilter(value);
              Navigator.pop(context);
            },
            valueEnumAll: CharacterGender.all,
          ),
          _buildFilterDropdown<CharacterSpecies>(
            title: 'Разновидность',
            valueEnum: vm.selectedSpecies,
            valuesEnum: CharacterSpecies.values,
            onChanged: (value) {
              vm.setSpeciesFilter(value);
              Navigator.pop(context);
            },
            valueEnumAll: CharacterSpecies.all,
          ),

          PopupMenuItem(
            child: TextButton(
              onPressed: () {
                vm.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Сбросить фильтры'),
            ),
          ),
        ];
      },
    );
  }

  PopupMenuEntry<dynamic> _buildFilterDropdown<T extends Enum>({
    required String title,
    required T? valueEnum,
    required List<T> valuesEnum,
    required Function(T?) onChanged,
    required T? valueEnumAll,
  }) {
    return PopupMenuItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          DropdownButton<T?>(
            value: valueEnum,
            isExpanded: true,
            items:
                valuesEnum.map((item) {
                  return DropdownMenuItem<T?>(
                    value: item == valueEnumAll ? null : item,
                    child: Text(item.name),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
