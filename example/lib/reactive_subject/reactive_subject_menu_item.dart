import 'package:flutter/material.dart';

class ReactiveSubjectMenuItemWidget extends StatelessWidget {
  final String caption;
  final String routeName;
  final bool isSelected;
  final Widget? icon;

  const ReactiveSubjectMenuItemWidget({
    super.key,
    required this.caption,
    required this.routeName,
    required String currentRoute,
    this.icon,
  }) : isSelected = currentRoute == routeName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(caption),
      leading: icon,
      selected: isSelected,
      onTap: () {
        if (isSelected) {
          // close drawer
          Navigator.pop(context);
          return;
        }
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
