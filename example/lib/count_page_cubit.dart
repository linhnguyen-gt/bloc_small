import 'package:bloc_small/bloc_small.dart';
import 'package:bloc_small_example/drawer/menu_drawer.dart';
import 'package:flutter/material.dart';

import 'cubit/cubit/count_cubit.dart';
import 'navigation/app_router.gr.dart';

@RoutePage()
class CounterPage extends BaseCubitPage<CountCubit> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      loadingKey: 'increment',
      child: Scaffold(
        drawer: const MenuDrawer(CounterRoute.name),
        appBar: AppBar(title: const Text('Counter Example')),
        body: Center(
          child: BlocBuilder<CountCubit, CountState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Count:',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    '${state.count}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => bloc.increment(),
              heroTag: 'increment',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () => bloc.decrement(),
              heroTag: 'decrement',
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
