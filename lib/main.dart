import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

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

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  int get length => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    if (index == -1) return;
    final oldPerson = _people[index];
    if (oldPerson.age != updatedPerson.age ||
        oldPerson.name != updatedPerson.name) {
      _people[index] = updatedPerson;
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider(
  (ref) => DataModel(),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('homePage'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataModel = ref.watch(peopleProvider);
          return ListView.builder(
            itemCount: dataModel.length,
            itemBuilder: (BuildContext context, int index) {
              final person = dataModel.people[index];
              return ListTile(
                title: Text(person.toString()),
                onTap: () async {
                  final updatedPerson =
                      await createOrUpdatePersonDialog(context, person);
                  if (updatedPerson != null) {
                    dataModel.update(updatedPerson);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await createOrUpdatePersonDialog(context);
          if (person != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.add(person);
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

class Person {
  final String name;
  final int age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  Person update({
    String? name,
    int? age,
  }) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      uuid: uuid,
    );
  }

  @override
  String toString() => '$name ($age years old)';

  @override
  bool operator ==(covariant Person other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

final nameController = TextEditingController();

final ageController = TextEditingController();

Future<Person?> createOrUpdatePersonDialog(BuildContext context,
    [Person? existingPerson]) async {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog<Person?>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        existingPerson != null ? 'Update a person' : 'Create a person',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Enter name here...',
            ),
            onChanged: (value) => name = value,
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(
              labelText: 'Enter age here...',
            ),
            onChanged: (value) => age = int.tryParse(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
          ),
        ),
        TextButton(
          onPressed: () {
            if (name == null && age == null) Navigator.pop(context);
            final newPerson = existingPerson != null
                ? existingPerson.update(name: name, age: age)
                : Person(name: name!, age: age!);
            Navigator.of(context).pop(newPerson);
          },
          child: Text(
            existingPerson != null ? 'Update' : 'Create',
          ),
        )
      ],
    ),
  );
}
