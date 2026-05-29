import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_repository/expense_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser> _userSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthDisplayNameUpdateRequested>(_onDisplayNameUpdateRequested);

    _userSubscription = _authRepository.user.listen(
      (AppUser user) => add(AuthUserChanged(user)),
      onError: (Object error) {
        debugPrint('AuthBloc user stream error: $error');
        add(const AuthUserChanged(null));
      },
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user ?? _authRepository.currentUser;
    if (user == null || user.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(user));
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(email: event.email, password: event.password);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }
      emit(AuthAuthenticated(user));
    } catch (error) {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null && !currentUser.isEmpty) {
        emit(AuthAuthenticated(currentUser));
        return;
      }
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthPasswordResetSent());
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> _onDisplayNameUpdateRequested(AuthDisplayNameUpdateRequested event, Emitter<AuthState> emit) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null || currentUser.isEmpty) return;
    emit(AuthProfileUpdating(currentUser));
    try {
      final updatedUser = await _authRepository.updateDisplayName(event.displayName);
      emit(AuthProfileUpdated(updatedUser));
    } catch (error) {
      emit(AuthProfileUpdateFailure(user: currentUser, message: _friendlyError(error)));
    }
  }

  String _friendlyError(Object error) {
    if (error is AuthRepositoryException) {
      switch (error.code) {
        case 'invalid-email': return 'The email address is not valid.';
        case 'user-disabled': return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential': return 'Email or password is incorrect.';
        case 'email-already-in-use': return 'An account already exists for this email.';
        case 'weak-password': return 'Password must be at least 6 characters.';
        case 'network-request-failed': return 'Check your internet connection.';
        case 'operation-not-allowed': return 'This sign-in method is not enabled.';
        case 'too-many-requests': return 'Too many attempts. Try again later.';
        default: return '${error.message} (${error.code})';
      }
    }
    return 'Error: $error';
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }
}
