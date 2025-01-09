import 'package:flutter/material.dart';

import '../navigation/app_router.gr.dart';
import 'menu_item.dart';

class MenuDrawer extends StatelessWidget {
  final String currentRoute;

  const MenuDrawer(this.currentRoute);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          MenuItemWidget(
            caption: 'Home',
            route: MyHomeRoute(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.home),
          ),
          MenuItemWidget(
            caption: 'Cubit',
            route: CounterRoute(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.numbers),
          ),
          MenuItemWidget(
            caption: 'Search Page',
            route: SearchRoute(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.search),
          ),
          const Divider(),
          MenuItemWidget(
            caption: 'Reactive Subject',
            route: ReactiveSubjectScreen(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.stream),
          ),
        ],
      ),
    );
  }
}
