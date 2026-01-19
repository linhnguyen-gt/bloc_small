import 'package:bloc_small/core/utils/reactive_subject/reactive_subject.dart';
import 'package:flutter/material.dart';

class ReactiveSubjectImprovementsDemo extends StatefulWidget {
  static const String route = '/reactive_subject_improvements_demo';

  const ReactiveSubjectImprovementsDemo({super.key});

  @override
  State<ReactiveSubjectImprovementsDemo> createState() =>
      _ReactiveSubjectImprovementsDemoState();
}

class _ReactiveSubjectImprovementsDemoState
    extends State<ReactiveSubjectImprovementsDemo> {
  late ReactiveSubject<String> _searchSubject;
  late ReactiveSubject<int> _counterSubject;
  late ReactiveSubject<String?> _nullableSubject;
  late ReactiveSubject<User> _userSubject;

  @override
  void initState() {
    super.initState();
    _initializeSubjects();
  }

  void _initializeSubjects() {
    // Search with debounce and distinct
    _searchSubject = ReactiveSubject<String>()
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .debug(tag: 'Search');

    // Counter with type safety improvements
    _counterSubject = ReactiveSubject<int>(initialValue: 0);

    // Nullable subject with whereNotNull
    _nullableSubject = ReactiveSubject<String?>();

    // User subject for distinctBy demo
    _userSubject = ReactiveSubject<User>();
  }

  @override
  void dispose() {
    _searchSubject.dispose();
    _counterSubject.dispose();
    _nullableSubject.dispose();
    _userSubject.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReactiveSubject Improvements Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchDemo(),
            const SizedBox(height: 24),
            _buildCounterDemo(),
            const SizedBox(height: 24),
            _buildNullSafetyDemo(),
            const SizedBox(height: 24),
            _buildUserDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search with Debounce & Distinct',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Type to search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _searchSubject.add(value),
            ),
            const SizedBox(height: 8),
            StreamBuilder<String>(
              stream: _searchSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Debounced search: ${snapshot.data}');
                }
                return const Text('Start typing...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Counter with Type Safety',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed:
                      () => _counterSubject.add(_counterSubject.value + 1),
                  child: const Text('+'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      () => _counterSubject.add(_counterSubject.value - 1),
                  child: const Text('-'),
                ),
                const SizedBox(width: 16),
                Text('Has value: ${_counterSubject.hasValue}'),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: _counterSubject.stream,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current value: ${_counterSubject.value}'),
                    Text('Value or null: ${_counterSubject.valueOrNull}'),
                    Text('Value or default: ${_counterSubject.valueOr(-1)}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNullSafetyDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Null Safety with whereNotNull',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _nullableSubject.add('Hello'),
                  child: const Text('Add "Hello"'),
                ),
                ElevatedButton(
                  onPressed: () => _nullableSubject.add(null),
                  child: const Text('Add null'),
                ),
                ElevatedButton(
                  onPressed: () => _nullableSubject.add('World'),
                  child: const Text('Add "World"'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<String?>(
              stream: _nullableSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Latest value: ${snapshot.data ?? "null"}');
                }
                return const Text('No values yet');
              },
            ),
            const SizedBox(height: 4),
            StreamBuilder<String>(
              stream:
                  _nullableSubject.stream
                      .where((value) => value != null)
                      .cast<String>(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Non-null value: ${snapshot.data}');
                }
                return const Text('No non-null values yet');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Demo with distinctBy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _userSubject.add(User(1, 'John', 25)),
                  child: const Text('Add John'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _userSubject.add(User(1, 'John Updated', 26)),
                  child: const Text('Update John'),
                ),
                ElevatedButton(
                  onPressed: () => _userSubject.add(User(2, 'Jane', 30)),
                  child: const Text('Add Jane'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<User>(
              stream: _userSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Text('Latest user: ${user.name} (${user.age})');
                }
                return const Text('No users yet');
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<User>(
              stream: _userSubject.distinctBy((user) => user.id).stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Text(
                    'Distinct user by ID: ${user.name} (${user.age})',
                  );
                }
                return const Text('No distinct users yet');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final int age;

  User(this.id, this.name, this.age);

  @override
  String toString() => 'User(id: $id, name: $name, age: $age)';
}
