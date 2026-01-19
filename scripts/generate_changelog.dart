#!/usr/bin/env dart
// Script to generate CHANGELOG.md entry from conventional commits.
///
/// Usage:
///   dart scripts/generate_changelog.dart VERSION
///
/// Example:
///   dart scripts/generate_changelog.dart 3.2.0

import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Error: Version argument required');
    stderr.writeln('Usage: dart scripts/generate_changelog.dart <version>');
    exit(1);
  }

  final version = args[0];
  final changelogFile = File('CHANGELOG.md');
  
  if (!await changelogFile.exists()) {
    stderr.writeln('Error: CHANGELOG.md not found');
    exit(1);
  }

  // Get last tag
  final lastTagResult = await Process.run(
    'git',
    ['describe', '--tags', '--abbrev=0'],
    runInShell: true,
  );

  String? lastTag;
  if (lastTagResult.exitCode == 0) {
    lastTag = lastTagResult.stdout.toString().trim();
  }

  // Get commits since last tag
  final commitRange = lastTag != null ? '$lastTag..HEAD' : 'HEAD';
  final commitsResult = await Process.run(
    'git',
    [
      'log',
      '--pretty=format:%H|%s|%b',
      commitRange,
    ],
    runInShell: true,
  );

  if (commitsResult.exitCode != 0) {
    stderr.writeln('Error: Failed to get commits');
    exit(1);
  }

  final commits = <Map<String, String>>[];
  for (final line in commitsResult.stdout.toString().trim().split('\n')) {
    if (line.isEmpty) {
      continue;
    }
    final parts = line.split('|');
    if (parts.length < 2) {
      continue;
    }
    commits.add({
      'hash': parts[0],
      'subject': parts[1],
      'body': parts.length > 2 ? parts.sublist(2).join('|') : '',
    });
  }

  if (commits.isEmpty) {
    stderr.writeln('No commits found since last tag');
    exit(0);
  }

  // Get repository URL for links
  final repoUrlResult = await Process.run(
    'git',
    ['config', '--get', 'remote.origin.url'],
    runInShell: true,
  );

  String repoUrl = 'https://github.com/linhnguyen-gt/bloc_small';
  if (repoUrlResult.exitCode == 0) {
    final url = repoUrlResult.stdout.toString().trim();
    // Convert SSH to HTTPS if needed
    if (url.startsWith('git@')) {
      repoUrl = url
          .replaceFirst('git@', 'https://')
          .replaceFirst(':', '/')
          .replaceFirst('.git', '');
    } else if (url.endsWith('.git')) {
      repoUrl = url.replaceFirst('.git', '');
    } else {
      repoUrl = url;
    }
  }

  // Parse and categorize commits
  final features = <String>[];
  final fixes = <String>[];
  final breaking = <String>[];
  final docs = <String>[];
  final refactor = <String>[];
  final perf = <String>[];
  final other = <String>[];

  for (final commit in commits) {
    final subject = commit['subject']!;
    final body = commit['body'] ?? '';
    final hash = commit['hash']!.substring(0, 7);
    final link = '$repoUrl/commit/${commit['hash']}';

    String? type;
    String? scope;
    String description;

    // Parse conventional commit: type(scope): description
    final match = RegExp(r'^(\w+)(?:\(([^)]+)\))?(!)?:\s*(.+)$').firstMatch(subject);
    
    if (match != null) {
      type = match.group(1)?.toLowerCase();
      scope = match.group(2);
      final isBreaking = match.group(3) == '!';
      description = match.group(4) ?? subject;

      if (isBreaking || body.toLowerCase().contains('breaking change')) {
        breaking.add('* $description ([$hash]($link))');
        continue;
      }
    } else {
      type = 'other';
      description = subject;
    }

    final entry = scope != null
        ? '* **$scope**: $description ([$hash]($link))'
        : '* $description ([$hash]($link))';

    switch (type) {
      case 'feat':
        features.add(entry);
        break;
      case 'fix':
        fixes.add(entry);
        break;
      case 'docs':
        docs.add(entry);
        break;
      case 'refactor':
        refactor.add(entry);
        break;
      case 'perf':
        perf.add(entry);
        break;
      default:
        other.add(entry);
    }
  }

  // Generate CHANGELOG entry
  final date = DateTime.now().toIso8601String().split('T')[0];
  final buffer = StringBuffer();
  
  buffer.writeln('## $version');
  buffer.writeln();
  buffer.writeln('*Released on $date*');
  buffer.writeln();

  if (breaking.isNotEmpty) {
    buffer.writeln('### Breaking Changes');
    buffer.writeln();
    for (final item in breaking) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (features.isNotEmpty) {
    buffer.writeln('### Features');
    buffer.writeln();
    for (final item in features) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (fixes.isNotEmpty) {
    buffer.writeln('### Fixes');
    buffer.writeln();
    for (final item in fixes) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (refactor.isNotEmpty) {
    buffer.writeln('### Refactoring');
    buffer.writeln();
    for (final item in refactor) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (perf.isNotEmpty) {
    buffer.writeln('### Performance');
    buffer.writeln();
    for (final item in perf) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (docs.isNotEmpty) {
    buffer.writeln('### Documentation');
    buffer.writeln();
    for (final item in docs) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  if (other.isNotEmpty) {
    buffer.writeln('### Other');
    buffer.writeln();
    for (final item in other) {
      buffer.writeln(item);
    }
    buffer.writeln();
  }

  // Prepend to existing CHANGELOG
  final existingContent = await changelogFile.readAsString();
  
  // Remove the "# Changelog" header if it exists and add it back
  final contentWithoutHeader = existingContent.replaceFirst(
    RegExp(r'^# Changelog\s*\n*', multiLine: true),
    '',
  );
  
  final newContent = '${'# Changelog\n\n'}${buffer.toString()}$contentWithoutHeader';
  await changelogFile.writeAsString(newContent);

  print('CHANGELOG updated for version $version');
}
