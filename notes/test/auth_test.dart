import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Auth', () {
    final provider = MockAuthProvider();

    test('Should not be initialized', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot login if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Provider should be initialized', () async {
      await provider.init();
      expect(provider.isInitialized, true);
    });

    test('User is null after init', () {
      expect(provider.currentUser, null);
    });

    test('Init less than in 2 seconds', () async {
      await provider.init();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should call login', () async {
      final badUserEmail = provider.createUser(
        email: 'not@email.com',
        password: 'password',
      );
      expect(badUserEmail,
          throwsA(const TypeMatcher<UserNotFoundAuthExcpetion>()));

      final badUserPwd = provider.createUser(
        email: 'good@email.com',
        password: 'notPassword',
      );
      expect(
          badUserPwd, throwsA(const TypeMatcher<WrongPasswordAuthExcpetion>()));

      final goodUser = await provider.createUser(
        email: 'good@email.com',
        password: 'password',
      );
      expect(provider.currentUser, goodUser);
      expect(goodUser.isEmailVerified, false);
    });

    test('Logged in user verify email', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'test',
        password: 'test',
      );

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthUser? _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    isUserInitialized();
    await Future.delayed(const Duration(seconds: 2));

    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    isUserInitialized();
    if (email == 'not@email.com') throw UserNotFoundAuthExcpetion();
    if (password == 'notPassword') throw WrongPasswordAuthExcpetion();

    const user = AuthUser(id: "1", isEmailVerified: false, email: 'test');
    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    isUserInitialized();
    if (_user == null) throw UserNotFoundAuthExcpetion();

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    isUserInitialized();
    final user = _user;
    if (user == null) throw UserNotFoundAuthExcpetion();

    const newUser = AuthUser(id: "1", isEmailVerified: true, email: 'test');
    _user = newUser;
  }

  void isUserInitialized() {
    if (!isInitialized) throw NotInitializedException();
  }
}
