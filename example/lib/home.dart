import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import 'bloc/count/count_bloc.dart';
import 'drawer/menu_drawer.dart';
import 'navigation/app_router.gr.dart';

@RoutePage()
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends BaseBlocPageState<MyHomePage, CountBloc> {
  @override
  Widget buildPage(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return buildLoadingOverlay(
      child: Scaffold(
        drawer: const MenuDrawer(MyHomeRoute.name),
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Flutter Bloc Demo"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('You have pushed the button this many times:'),
              BlocBuilder<CountBloc, CountState>(
                builder: (context, state) {
                  return Text('${state.count}');
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomFloatingActionButton(
              onPressed: () => bloc.add(Increment()),
              tooltip: 'Increment',
              child: Icon(Icons.add, color: Colors.white),
            ),
            SizedBox(width: 10),
            CustomFloatingActionButton(
              onPressed: () => bloc.add(Decrement()),
              tooltip: 'Decrement',
              child: Icon(Icons.remove, color: Colors.white),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String tooltip;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 6.0,
      fillColor: Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.all(8.0),
      shape: CircleBorder(),
      constraints: BoxConstraints(minWidth: 56.0, minHeight: 56.0),
      child: child,
    );
  }
}
