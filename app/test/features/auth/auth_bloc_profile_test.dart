import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kapok_app/core/enums/user_role.dart';
import 'package:kapok_app/core/error/exceptions.dart';
import 'package:kapok_app/data/models/user_model.dart';
import 'package:kapok_app/data/repositories/auth_repository.dart';
import 'package:kapok_app/features/auth/bloc/auth_bloc.dart';
import 'package:kapok_app/features/auth/bloc/auth_event.dart';
import 'package:kapok_app/features/auth/bloc/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  final user = UserModel(
    id: 'u1',
    name: 'Alice Tester',
    email: 'alice@example.com',
    userRole: UserRole.teamMember,
    role: 'Medical',
    teamId: 'team-1',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  setUpAll(() => registerFallbackValue(user));

  setUp(() => repository = _MockAuthRepository());

  group('ProfileUpdateRequested (Edit Profile)', () {
    final updated = user.copyWith(name: 'Alice Updated', role: 'Plumbing');

    blocTest<AuthBloc, AuthState>(
      'saves name and profession and keeps isNewSignup',
      setUp: () => when(() => repository.updateUserProfile(any()))
          .thenAnswer((_) async => updated),
      build: () => AuthBloc(authRepository: repository),
      seed: () => AuthAuthenticated(user: user, isNewSignup: true),
      act: (bloc) => bloc.add(const ProfileUpdateRequested(
        name: 'Alice Updated',
        role: 'Plumbing',
      )),
      expect: () => [AuthAuthenticated(user: updated, isNewSignup: true)],
      verify: (_) {
        final saved = verify(() => repository.updateUserProfile(captureAny()))
            .captured
            .single as UserModel;
        expect(saved.name, 'Alice Updated');
        expect(saved.role, 'Plumbing');
      },
    );

    test('calls onComplete(null) on success', () async {
      when(() => repository.updateUserProfile(any()))
          .thenAnswer((_) async => updated);
      final bloc = AuthBloc(authRepository: repository)
        ..emit(AuthAuthenticated(user: user));
      final results = <String?>[];
      bloc.add(ProfileUpdateRequested(
        name: 'Alice Updated',
        role: 'Plumbing',
        onComplete: results.add,
      ));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(results, [null]);
      await bloc.close();
    });

    test('reports the error and leaves state untouched on failure', () async {
      when(() => repository.updateUserProfile(any()))
          .thenThrow(const AuthException(message: 'Failed to update profile'));
      final bloc = AuthBloc(authRepository: repository)
        ..emit(AuthAuthenticated(user: user));
      final results = <String?>[];
      bloc.add(ProfileUpdateRequested(name: 'X', onComplete: results.add));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(results, ['Failed to update profile']);
      expect(bloc.state, AuthAuthenticated(user: user));
      await bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'full-model updates (onboarding) still clear isNewSignup',
      setUp: () => when(() => repository.updateUserProfile(any()))
          .thenAnswer((inv) async => inv.positionalArguments.first as UserModel),
      build: () => AuthBloc(authRepository: repository),
      seed: () => AuthAuthenticated(user: user, isNewSignup: true),
      act: (bloc) => bloc.add(ProfileUpdateRequested(user: user.copyWith(teamId: 't2'))),
      expect: () => [AuthAuthenticated(user: user.copyWith(teamId: 't2'))],
    );
  });

  group('DeleteAccountRequested', () {
    test('passes the password through and reports success', () async {
      when(() => repository.deleteAccount(password: any(named: 'password')))
          .thenAnswer((_) async {});
      final bloc = AuthBloc(authRepository: repository)
        ..emit(AuthAuthenticated(user: user));
      final results = <String?>[];
      bloc.add(DeleteAccountRequested(password: 'hunter2', onComplete: results.add));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      verify(() => repository.deleteAccount(password: 'hunter2')).called(1);
      expect(results, [null]);
      expect(bloc.state, const AuthUnauthenticated());
      await bloc.close();
    });

    test('keeps the user signed in and reports a wrong password', () async {
      when(() => repository.deleteAccount(password: any(named: 'password')))
          .thenThrow(const AuthException(message: 'Incorrect password. Please try again.'));
      final bloc = AuthBloc(authRepository: repository)
        ..emit(AuthAuthenticated(user: user));
      final results = <String?>[];
      bloc.add(DeleteAccountRequested(password: 'nope', onComplete: results.add));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(results, ['Incorrect password. Please try again.']);
      expect(bloc.state, AuthAuthenticated(user: user));
      await bloc.close();
    });
  });
}
