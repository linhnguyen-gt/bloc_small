import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A platform-aware loading indicator widget.
///
/// Shows [CupertinoActivityIndicator] on iOS and [CircularProgressIndicator] on other platforms.
///
/// Usage:
/// ```dart
/// LoadingIndicator(
///   backgroundColor: Colors.black12, // optional background color
/// )
/// ```
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.backgroundColor = Colors.white12,
  });

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
    );
  }
}
