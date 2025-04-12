import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/di/di_scope_provider.dart';
import 'package:rick_and_morty/domain/enums/filter_enum.dart';
import 'package:rick_and_morty/domain/models/api_response.dart';
import 'package:rick_and_morty/domain/models/character_model.dart';
import 'package:rick_and_morty/domain/models/info_model.dart';
import 'package:rick_and_morty/features/home/home_vm.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    vm = HomeViewModel(repository: DiScopeProvider.of(context)!.repository);
    vm.loadPage(vm.currentPage);
    vm.loadFavorites(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Персонажи Рик и Морти'),
            actions:
                vm.isOnline
                    ? [FilterDropDownButton(vm: vm), const SizedBox(width: 8)]
                    : null,
          ),
          body: FutureBuilder<ApiResponse>(
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
          ),
        );
      },
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
          if (info.next != null && info.pages != vm.currentPage)
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
        onTap: () => fullViewInfoCharacter(context, typeCharacter),
      ),
    );
  }

  Future<dynamic> fullViewInfoCharacter(
    BuildContext context,
    String typeCharacter,
  ) {
    return showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                CachedNetworkImage(imageUrl: character.image),
                Text('Имя: ${character.name}'),
                Text('Пол: ${character.gender}'),
                Text('Вид: ${character.species}'),
                Text(typeCharacter),
                Text('Статус жизни: ${character.status}'),
              ],
            ),
          ),
    );
  }
}

class FilterDropDownButton extends StatelessWidget {
  const FilterDropDownButton({super.key, required this.vm});

  final HomeViewModel vm;

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
