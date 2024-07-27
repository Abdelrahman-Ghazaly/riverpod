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

const names = [
  'Alice',
  'Bob',
  'Charlie',
  'Diana',
  'Eve',
  'Frank',
  'Grace',
  'Hank',
  'Ivy',
  'Jack',
  'Karen',
  'Leo',
  'Mona',
  'Nate',
  'Olivia'
];

final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(
    const Duration(seconds: 1),
    (i) => i + 1,
  ),
);

///! Depricated. Has smooth addition to the list and doesn't rebuil
///! the whole [ListView], and the loading state.
// final namesProvider = StreamProvider(
//   (ref) => ref.watch(tickerProvider.stream).map(
//         (count) => names.getRange(0, count).toList(),
//       ),
// );

///! Current work around. Causes the entire list to be rebuit and
///! the Loading satate is called with every rebuild.
final namesProvider = FutureProvider<List<String>>((ref) async {
  final count = await ref.watch(tickerProvider.future);
  return names.getRange(0, count).toList();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreamProvider'),
      ),
      body: names.when(
        data: (names) {
          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(names[index]),
              );
            },
          );
        },
        error: (error, stackTrace) => const Center(
          child: Text('Reached the end of the list'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
