import 'package:bloc_small/auto_route.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String caption;
  final PageRouteInfo route;
  final String currentRoute;
  final Icon? icon;

  const MenuItemWidget({
    required this.caption,
    required this.route,
    required this.currentRoute,
    this.icon,
  });

  bool get isSelected => route.routeName == currentRoute;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(caption),
      leading: icon,
      selected: isSelected,
      onTap: () async {
        Navigator.of(context).pop();
        if (isSelected) return;
        await context.router.replace(route);
      },
    );
  }
}
