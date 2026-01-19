#!/usr/bin/env dart
// Script to automatically bump version based on conventional commits.
//
// Usage:
//   dart scripts/bump_version.dart
//
// Version bump rules:
// - feat: → MINOR (3.1.1 → 3.2.0)
// - fix: → PATCH (3.1.1 → 3.1.2)
// - BREAKING CHANGE or ! → MAJOR (3.1.1 → 4.0.0)
// - Other → PATCH

import 'dart:io';

void main() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    stderr.writeln('Error: pubspec.yaml not found');
    exit(1);
  }

  // Read current version
  final pubspecContent = await pubspecFile.readAsString();
  final versionMatch = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)', multiLine: true)
      .firstMatch(pubspecContent);
  
  if (versionMatch == null) {
    stderr.writeln('Error: Could not find version in pubspec.yaml');
    exit(1);
  }

  final major = int.parse(versionMatch.group(1)!);
  final minor = int.parse(versionMatch.group(2)!);
  final patch = int.parse(versionMatch.group(3)!);
  final currentVersion = '$major.$minor.$patch';

  // Get commits since last tag
  final lastTagResult = await Process.run(
    'git',
    ['describe', '--tags', '--abbrev=0'],
    runInShell: true,
  );

  String? lastTag;
  if (lastTagResult.exitCode == 0) {
    lastTag = lastTagResult.stdout.toString().trim();
  }

  // Get commits since last tag (or all commits if no tag)
  final commitRange = lastTag != null ? '$lastTag..HEAD' : 'HEAD';
  final commitsResult = await Process.run(
    'git',
    ['log', '--pretty=format:%s', commitRange],
    runInShell: true,
  );

  if (commitsResult.exitCode != 0) {
    stderr.writeln('Error: Failed to get commits');
    exit(1);
  }

  final commits = commitsResult.stdout.toString().trim().split('\n')
      .where((c) => c.isNotEmpty)
      .toList();

  if (commits.isEmpty && lastTag != null) {
    // No new commits, no version bump needed
    // Output current version but don't update pubspec.yaml
    stdout.writeln(currentVersion);
    exit(0);
  }

  // Determine bump type
  String bumpType = 'patch';
  bool hasBreakingChange = false;
  bool hasFeature = false;

  for (final commit in commits) {
    final commitLower = commit.toLowerCase();
    
    // Check for breaking changes
    if (commitLower.contains('breaking change') ||
        commitLower.contains('!') ||
        commit.startsWith('BREAKING CHANGE')) {
      hasBreakingChange = true;
      break;
    }
    
    // Check for features
    if (commit.startsWith('feat') || commit.startsWith('feat(')) {
      hasFeature = true;
    }
  }

  if (hasBreakingChange) {
    bumpType = 'major';
  } else if (hasFeature) {
    bumpType = 'minor';
  } else {
    bumpType = 'patch';
  }

  // Calculate new version
  int newMajor = major;
  int newMinor = minor;
  int newPatch = patch;

  switch (bumpType) {
    case 'major':
      newMajor++;
      newMinor = 0;
      newPatch = 0;
      break;
    case 'minor':
      newMinor++;
      newPatch = 0;
      break;
    case 'patch':
      newPatch++;
      break;
  }

  final newVersion = '$newMajor.$newMinor.$newPatch';

  // Update pubspec.yaml
  final updatedContent = pubspecContent.replaceFirst(
    RegExp(r'^version:\s*\d+\.\d+\.\d+', multiLine: true),
    'version: $newVersion',
  );

  await pubspecFile.writeAsString(updatedContent);

  // Output new version for use in workflow
  stdout.writeln(newVersion);
  
  // Output bump type for logging
  stderr.writeln('Version bumped: $currentVersion → $newVersion ($bumpType)');
}
