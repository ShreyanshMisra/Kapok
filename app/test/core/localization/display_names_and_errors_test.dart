import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kapok_app/core/enums/task_category.dart';
import 'package:kapok_app/core/enums/task_priority.dart';
import 'package:kapok_app/core/enums/task_status.dart';
import 'package:kapok_app/core/enums/user_role.dart';
import 'package:kapok_app/core/error/error_message.dart';
import 'package:kapok_app/core/error/exceptions.dart';
import 'package:kapok_app/core/localization/app_localizations.dart';

void main() {
  final en = AppLocalizations(const Locale('en'));
  final es = AppLocalizations(const Locale('es'));

  group('display names', () {
    test('every enum value has a translated name in both languages', () {
      for (final l in [en, es]) {
        for (final s in TaskStatus.values) {
          expect(l.taskStatusName(s), isNotEmpty);
        }
        for (final p in TaskPriority.values) {
          expect(l.taskPriorityName(p), isNotEmpty);
        }
        for (final c in TaskCategory.values) {
          expect(l.taskCategoryName(c), isNotEmpty);
        }
        for (final r in UserRole.values) {
          expect(l.userRoleName(r), isNotEmpty);
        }
      }
    });

    test('Spanish names differ from the stored English values', () {
      expect(es.taskStatusName(TaskStatus.inProgress), isNot('In Progress'));
      expect(es.userRoleName(UserRole.teamLeader), isNot('Team Leader'));
      expect(es.taskCategoryName(TaskCategory.medical), isNot('Medical'));
    });

    test('professionName matches stored values case-insensitively', () {
      expect(en.professionName('Medical'), en.medical);
      expect(es.professionName('medical'), es.medical);
      expect(es.professionName(' Transportation '), es.transportation);
      // Unknown values are shown as stored rather than dropped.
      expect(es.professionName('Logistics'), 'Logistics');
    });

    test('placeholders are filled', () {
      expect(es.youHaveLeftTeam('Alpha'), contains('Alpha'));
      expect(en.memberWillBeRemovedFrom('Ana', 'Alpha'), 'Ana will be removed from Alpha.');
      expect(en.tilesProgress('3', '10'), '3/10 tiles');
    });
  });

  group('userMessageFor', () {
    test('uses the message of app exceptions without the type prefix', () {
      const e = DatabaseException(message: 'Failed to load teams. Please try again.');
      expect(e.toString(), startsWith('DatabaseException:'));
      expect(userMessageFor(e), 'Failed to load teams. Please try again.');
    });

    test('falls back for other errors instead of showing raw text', () {
      expect(userMessageFor(Exception('[cloud_firestore/permission-denied] x')),
          genericErrorMessage);
      expect(userMessageFor(StateError('bad'), fallback: 'Custom'), 'Custom');
    });

    test('falls back when an app exception has an empty message', () {
      expect(userMessageFor(const AuthException(message: '  ')), genericErrorMessage);
    });
  });
}
