// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const HomePage(),
      ),
    );
  }
}

class Film {
  final String id;
  final String name;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.name,
    required this.description,
    required this.isFavorite,
  });

  Film favorite(bool isFavorite) {
    return Film(
      id: id,
      name: name,
      description: description,
      isFavorite: isFavorite,
    );
  }

  @override
  bool operator ==(covariant Film other) {
    if (identical(this, other)) return true;

    return other.id == id && other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^ isFavorite.hashCode;
  }
}

const allFilms = [
  Film(
    id: '1',
    name: 'name1',
    description: 'description1',
    isFavorite: false,
  ),
  Film(
    id: '2',
    name: 'name2',
    description: 'description2',
    isFavorite: false,
  ),
  Film(
    id: '3',
    name: 'name3',
    description: 'description3',
    isFavorite: false,
  ),
  Film(
    id: '4',
    name: 'name4',
    description: 'description4',
    isFavorite: false,
  ),
  Film(
    id: '5',
    name: 'name5',
    description: 'description5',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map(
          (thisFilm) =>
              thisFilm.id == film.id ? thisFilm.favorite(isFavorite) : thisFilm,
        )
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (_) => FavoriteStatus.all,
);

final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (_) => FilmsNotifier(),
);

final favoriteProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite),
);

final notFavoriteProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);
              return switch (filter) {
                FavoriteStatus.all => FilmsWidget(provider: allFilmsProvider),
                FavoriteStatus.favorite =>
                  FilmsWidget(provider: favoriteProvider),
                FavoriteStatus.notFavorite =>
                  FilmsWidget(provider: notFavoriteProvider),
              };
            },
          )
        ],
      ),
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  const FilmsWidget({required this.provider, super.key});

  final AlwaysAliveProviderBase<Iterable<Film>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: films.length,
      itemBuilder: (BuildContext context, int index) {
        final film = films.elementAt(index);
        final favoriteIcon =
            film.isFavorite ? Icons.favorite : Icons.favorite_border;

        return ListTile(
          title: Text(film.name),
          subtitle: Text(film.description),
          trailing: IconButton(
            onPressed: () {
              final isFavorite = !film.isFavorite;
              ref.read(allFilmsProvider.notifier).update(film, isFavorite);
            },
            icon: Icon(favoriteIcon),
          ),
        );
      },
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavoriteStatus.values
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  ))
              .toList(),
          onChanged: (favoriteStatus) {
            ref.read(favoriteStatusProvider.notifier).state = favoriteStatus!;
          },
        );
      },
    );
  }
}
