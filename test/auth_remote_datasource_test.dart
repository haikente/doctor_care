import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_care/data/datasources/auth_remote_datasource.dart';
import 'package:doctor_care/data/models/user_model.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  User,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
  });

  group('signInWithGoogle', () {
    test(
      'should return UserModel when Google Sign-In and Firebase Auth are successful and create user in Firestore',
      () async {
        // Arrange
        dataSource = AuthRemoteDataSourceImpl(
          firebaseAuth: mockFirebaseAuth,
          firestore: mockFirestore,
          googleSignIn: mockGoogleSignIn,
        );

        final googleAccount = MockGoogleSignInAccount();
        final googleAuth = MockGoogleSignInAuthentication();
        final userCredential = MockUserCredential();
        final firebaseUser = MockUser();

        // Google Sign In Mocks
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => googleAccount);
        when(googleAccount.authentication).thenAnswer((_) async => googleAuth);
        when(googleAuth.accessToken).thenReturn('access_token');
        when(googleAuth.idToken).thenReturn('id_token');

        // Firebase Auth Mocks
        when(
          mockFirebaseAuth.signInWithCredential(any),
        ).thenAnswer((_) async => userCredential);
        when(userCredential.user).thenReturn(firebaseUser);
        when(firebaseUser.uid).thenReturn('test_uid');
        when(firebaseUser.email).thenReturn('test@example.com');

        // Firestore Mocks
        final usersCollection = MockCollectionReference<Map<String, dynamic>>();
        final userDoc = MockDocumentReference<Map<String, dynamic>>();
        final docSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(usersCollection);
        when(usersCollection.doc('test_uid')).thenReturn(userDoc);

        // Simulate user checks
        when(userDoc.get()).thenAnswer((_) async => docSnapshot);
        // First check (simulating _getUserRole) fails or returns null/empty, or doc doesn't exist
        // The code calls _getUserRole which calls get().
        // If doc exists: return data.
        // If not: return 'patient'.
        // Then code checks again if doc exists to set it.

        // Let's verify the robust flow:
        // 1. _getUserRole calls get(). Let's say it returns snapshot that doesn't exist.
        when(docSnapshot.exists).thenReturn(false);
        when(docSnapshot.data()).thenReturn(null);

        // 2. _getUserRole returns 'patient' (catch block or else branch).

        // 3. Code then checks docSnapshot again (WAIT, the code calls get() TWICE?
        // logic: `final docSnapshot = await firestore...get();` is done in `_getUserRole` inside private method.
        // And then checking again `if (!docSnapshot.exists)` which is a NEW call.
        // So we need to expect multiple calls or use the same mock.

        // Note: The implementation has `_getUserRole` private method calling valid Firestore logic?
        // Actually `_getUserRole` calls `firestore.collection('users').doc(uid).get()`.
        // And the main method `signInWithGoogle` calls `firestore.collection('users').doc(user.uid).get()` later.
        // So we expect 2 calls to `get()`.

        when(userDoc.set(any)).thenAnswer((_) async => <void>{});

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result, isA<UserModel>());
        expect(result.email, 'test@example.com');
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        // Verify firestore set was called to create the user
        verify(userDoc.set(any)).called(greaterThanOrEqualTo(1));
      },
    );
  });
}
